-- dji-dumlv1-hdlink-ext.lua
-- Dissector for DUML cmd_set=0x09 (HD Link), cmd_id=0xF6: OFDM Channel Plan Push
--
-- Payload layout (163 bytes, confirmed by packet analysis):
--   [0]        uint8    unk0 (unknown, seen 0x32)
--   [1]        uint8    unk1 (unknown, seen 0x02)
--   [2]        uint8    num_active  (active channel count, ≤32)
--   [3..66]   uint16 LE[32]  slot_freq_id[]   (64 bytes)
--   [67..98]  uint8[32]      slot_index[]
--   [99..130] uint8[32]      slot_quality[]   0-100 %
--   [131..162] uint8[32]     slot_flags[]
--
-- Frequency decoding: stored uint16 → actual MHz
--   U-NII-3  (5735-5835 MHz): stored 2300..2700 → +3186
--   U-NII-2C (5470-5725 MHz): stored 2300..2700 where result ≥5470 (handled above)
--   U-NII-2A (5250-5470 MHz): stored 2100..2299 where result ≥5250
--   U-NII-1  (5150-5250 MHz): stored 2100..2299 where result ≥5150
--   2.4 GHz  (2400-2500 MHz): stored 1000..1199 → +1399

local DUML_HDR = 11   -- bytes before payload in a DUML V1 frame

local FREQ_OFF  = 3         -- uint16 LE × 32  (64 bytes)
local IDX_OFF   = 3 + 64    -- = 67
local QUAL_OFF  = 67 + 32   -- = 99
local FLAGS_OFF = 99 + 32   -- = 131

local p_ch = Proto("dji_dumlv1_ch_plan", "DJI DUMLv1 HD Link Channel Plan")
local fld = {
    unk0       = ProtoField.uint8 ("dji_dumlv1.hdlnk_ch_plan_unk0",       "Unknown[0]",   base.HEX),
    unk1       = ProtoField.uint8 ("dji_dumlv1.hdlnk_ch_plan_unk1",       "Unknown[1]",   base.HEX),
    num_active = ProtoField.uint8 ("dji_dumlv1.hdlnk_ch_plan_num_active", "Active Slots", base.DEC),
    channel    = ProtoField.uint16("dji_dumlv1.hdlnk_ch_plan_channel",    "Channel",      base.HEX),
    ch_freq    = ProtoField.uint16("dji_dumlv1.hdlnk_ch_plan_ch_freq",    "Freq",         base.DEC),
    ch_quality = ProtoField.uint8 ("dji_dumlv1.hdlnk_ch_plan_ch_quality", "Quality",      base.DEC),
    ch_index   = ProtoField.uint8 ("dji_dumlv1.hdlnk_ch_plan_ch_index",   "Slot Index",   base.DEC),
    ch_flags   = ProtoField.uint8 ("dji_dumlv1.hdlnk_ch_plan_ch_flags",   "Flags",        base.HEX),
}
p_ch.fields = { fld.unk0, fld.unk1, fld.num_active, fld.channel,
                fld.ch_freq, fld.ch_quality, fld.ch_index, fld.ch_flags }

local function decode_ofdm_freq_mhz(stored)
    if stored == 0 then return nil end
    if stored >= 2300 and stored <= 2700 then
        return stored + 3186
    elseif stored >= 2100 and stored < 2300 then
        return stored + 3066
    elseif stored >= 1000 and stored < 1200 then
        return stored + 1399
    end
    return nil
end

local function band_name(mhz)
    if not mhz then return "" end
    if mhz >= 5735 then return "U-NII-3"
    elseif mhz >= 5470 then return "U-NII-2C"
    elseif mhz >= 5250 then return "U-NII-2A"
    elseif mhz >= 5150 then return "U-NII-1"
    elseif mhz >= 2400 then return "2.4GHz"
    end
    return ""
end

local function hd_link_channel_plan_dissector(pkt_length, buffer, pinfo, subtree)
    local payload_len = pkt_length - DUML_HDR - 2
    if payload_len < 3 then
        subtree:add_expert_info(PI_MALFORMED, PI_ERROR,
            "HDLnk Channel Plan: payload too short (" .. payload_len .. " bytes)")
        return
    end

    local p = buffer(DUML_HDR, payload_len)

    subtree:add(fld.unk0, p(0, 1))
    subtree:add(fld.unk1, p(1, 1))

    local nactive = p(2, 1):uint()
    if nactive > 32 then nactive = 32 end
    local na_node = subtree:add(fld.num_active, p(2, 1))
    na_node:set_text("Active Slots: " .. nactive)

    for i = 0, nactive - 1 do
        local off_freq  = FREQ_OFF  + i * 2
        local off_idx   = IDX_OFF   + i
        local off_qual  = QUAL_OFF  + i
        local off_flags = FLAGS_OFF + i

        if off_flags >= payload_len then break end

        local stored_fid = (off_freq + 1 < payload_len) and p(off_freq, 2):le_uint() or 0
        local slot_idx   = (off_idx   < payload_len) and p(off_idx,   1):uint() or 0
        local slot_qual  = (off_qual  < payload_len) and p(off_qual,  1):uint() or 0
        local slot_flags = (off_flags < payload_len) and p(off_flags, 1):uint() or 0

        local freq_mhz = decode_ofdm_freq_mhz(stored_fid)
        local band     = band_name(freq_mhz)
        local freq_str
        if freq_mhz then
            freq_str = freq_mhz .. " MHz (" .. band .. ")"
        else
            freq_str = "unknown (raw=0x" .. string.format("%04x", stored_fid) .. ")"
        end

        local label = string.format("Ch[%02d] %-26s  q=%d%%  idx=%d  flags=0x%02x",
            i, freq_str, slot_qual, slot_idx, slot_flags)

        -- anchor channel row on the freq bytes for clean PDML byte range
        local ch_node = subtree:add_le(fld.channel, p(off_freq, 2))
        ch_node:set_text(label)

        local freq_node = ch_node:add_le(fld.ch_freq, p(off_freq, 2))
        freq_node:set_text("Freq: " .. freq_str)

        if off_qual  < payload_len then
            local qn = ch_node:add(fld.ch_quality, p(off_qual, 1))
            qn:set_text("Quality: " .. slot_qual .. "%")
        end
        if off_idx   < payload_len then ch_node:add(fld.ch_index, p(off_idx,   1)) end
        if off_flags < payload_len then ch_node:add(fld.ch_flags,  p(off_flags, 1)) end
    end

    pinfo.cols.info:append(string.format(" [HDLnk ChPlan %d slots]", nactive))
end

-- Register into the global cmd dissect table populated by dji-dumlv1-proto.lua.
if DJI_DUMLv1_CMD_DISSECT and DJI_DUMLv1_CMD_DISSECT[0x09] then
    DJI_DUMLv1_CMD_DISSECT[0x09][0xf6] = hd_link_channel_plan_dissector
end

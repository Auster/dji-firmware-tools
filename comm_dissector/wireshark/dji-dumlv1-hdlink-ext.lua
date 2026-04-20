-- DJI DUML v1 HD Link Extended Dissector
-- Extension for dji-dumlv1-proto.lua, cmd_set 0x09 (HD Link)
-- Adds dissectors for previously undocumented HD Link commands.

local f = DJI_DUMLv1_PROTO.fields

-- ===========================================================================
-- HD Link - HDLnk Channel Plan Push - 0xF6
-- ===========================================================================
--
-- Sent by HD Link GND (type 0x0E) → PC (type 0x0A) at approximately 10 Hz.
-- Reports the OFDM frequency-hopping channel plan and per-channel link quality.
--
-- Payload is always 163 bytes, fixed 32-slot Structure-of-Arrays (SoA):
--
--   Offset  Size        Description
--   ------  ----------  --------------------------------------------------
--   0       1           Sub-type (observed: 0x32)
--   1       1           Bandwidth mode (0=20 MHz, 2=40 MHz)
--   2       1           n_active: number of populated slots (e.g. 10 or 22)
--   3       32×uint16   OFDM channel IDs (little-endian, DJI internal units)
--   67      32×uint8    1-based channel indices for each slot
--   99      32×uint8    Signal quality, 0-100 %
--   131     32×uint8    Flags: bit0=in-hop-pool, bit1=DFS channel
--
-- Total: 3 + 64 + 32 + 32 + 32 = 163 bytes.
--
-- Frequency encoding:
--   The stored uint16 value maps to a centre frequency in MHz as follows:
--     stored 2300-2700 → 5 GHz U-NII-2C/3   (add 3186)
--     stored 2100-2300 → 5 GHz U-NII-1/2A   (add 3066)
--     stored 1000-1200 → 2.4 GHz             (add 1399)
--
-- Example observed channel plans:
--   40 MHz mode (10 ch): 5510, 5550, 5670, 5270, 5310, 5770, 5829, 5190, 5230, 2445 MHz
--   20 MHz mode (22 ch): 5500-5580, 5660-5700, 5260-5320, 5760-5838, 5180-5240, 2435, 2461 MHz

local HDLNK_BANDWIDTH_ENUM = {
    [0] = '20 MHz',
    [1] = '30 MHz',
    [2] = '40 MHz',
    [3] = '80 MHz',
}

f.hd_link_ch_plan_sub_type  = ProtoField.uint8 ("dji_dumlv1.hd_link_ch_plan_sub_type",
    "Sub Type", base.HEX, nil, nil, "Always 0x32 in observed packets")
f.hd_link_ch_plan_bandwidth = ProtoField.uint8 ("dji_dumlv1.hd_link_ch_plan_bandwidth",
    "Bandwidth Mode", base.DEC, HDLNK_BANDWIDTH_ENUM)
f.hd_link_ch_plan_n_active  = ProtoField.uint8 ("dji_dumlv1.hd_link_ch_plan_n_active",
    "Active Channels", base.DEC, nil, nil, "Number of populated slots in each SoA array")
f.hd_link_ch_plan_freq_id   = ProtoField.uint16("dji_dumlv1.hd_link_ch_plan_freq_id",
    "Freq ID", base.HEX, nil, nil, "DJI internal OFDM channel identifier (LE uint16)")
f.hd_link_ch_plan_idx       = ProtoField.uint8 ("dji_dumlv1.hd_link_ch_plan_idx",
    "Channel Index", base.DEC, nil, nil, "1-based slot index")
f.hd_link_ch_plan_quality   = ProtoField.uint8 ("dji_dumlv1.hd_link_ch_plan_quality",
    "Signal Quality", base.DEC, nil, nil, "0-100 %")
f.hd_link_ch_plan_flags     = ProtoField.uint8 ("dji_dumlv1.hd_link_ch_plan_flags",
    "Flags", base.HEX)
f.hd_link_ch_plan_flag_hop  = ProtoField.uint8 ("dji_dumlv1.hd_link_ch_plan_flag_hop",
    "In Hop Pool", base.DEC, nil, 0x01, "Bit 0: channel is in the active frequency-hop pool")
f.hd_link_ch_plan_flag_dfs  = ProtoField.uint8 ("dji_dumlv1.hd_link_ch_plan_flag_dfs",
    "DFS Channel", base.DEC, nil, 0x02, "Bit 1: channel requires Dynamic Frequency Selection")

-- Decode a DJI OFDM channel ID to centre frequency in MHz.
-- Returns an integer MHz value, or nil if the stored value is zero or unknown.
local function decode_ofdm_freq_mhz(stored)
    if stored == 0 then return nil end
    if stored >= 2300 and stored <= 2700 then
        return stored + 3186   -- 5 GHz U-NII-2C / U-NII-3  (5486 – 5886 MHz)
    elseif stored >= 2100 and stored < 2300 then
        return stored + 3066   -- 5 GHz U-NII-1 / U-NII-2A  (5166 – 5366 MHz)
    elseif stored >= 1000 and stored < 1200 then
        return stored + 1399   -- 2.4 GHz                    (2399 – 2599 MHz)
    end
    return nil   -- outside known bands; display raw value only
end

local CH_PLAN_SLOT_COUNT = 32
local CH_PLAN_PAYLOAD_LEN = 163

local function hd_link_channel_plan_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    pinfo.cols.info:set("HDLnk Channel Plan Push")

    if payload:len() < 3 then
        subtree:add_expert_info(PI_MALFORMED, PI_ERROR,
            "HDLnk Channel Plan: payload too short (need at least 3 bytes)")
        return
    end

    -- 3-byte header
    subtree:add_le(f.hd_link_ch_plan_sub_type,  payload(0, 1))
    subtree:add_le(f.hd_link_ch_plan_bandwidth, payload(1, 1))
    local n_item   = subtree:add_le(f.hd_link_ch_plan_n_active, payload(2, 1))
    local n_active = payload(2, 1):uint()
    offset = 3

    if n_active > CH_PLAN_SLOT_COUNT then
        n_item:add_expert_info(PI_PROTOCOL, PI_WARN,
            string.format("n_active=%d exceeds max slot count %d; clamping",
                n_active, CH_PLAN_SLOT_COUNT))
        n_active = CH_PLAN_SLOT_COUNT
    end

    -- Minimum required payload for all 4 SoA arrays
    if payload:len() < CH_PLAN_PAYLOAD_LEN then
        subtree:add_expert_info(PI_MALFORMED, PI_ERROR,
            string.format("HDLnk Channel Plan: payload %d bytes, expected %d",
                payload:len(), CH_PLAN_PAYLOAD_LEN))
        return
    end

    -- Per-channel subtrees.
    -- Each active slot i has data spread across 4 non-contiguous arrays:
    --   freq_id  at p[3  + i*2]   (uint16 LE)
    --   index    at p[67 + i]     (uint8)
    --   quality  at p[99 + i]     (uint8)
    --   flags    at p[131 + i]    (uint8)
    for i = 0, n_active - 1 do
        local freq_off = 3   + i * 2
        local idx_off  = 67  + i
        local qual_off = 99  + i
        local flag_off = 131 + i

        local stored   = payload(freq_off, 2):le_uint()
        local freq_mhz = decode_ofdm_freq_mhz(stored)
        local qual_val = payload(qual_off, 1):uint()
        local flag_val = payload(flag_off, 1):uint()

        -- Build a concise label for the subtree header
        local label
        if freq_mhz then
            local flags_str = ""
            if bit32.band(flag_val, 0x01) ~= 0 then flags_str = flags_str .. " hop" end
            if bit32.band(flag_val, 0x02) ~= 0 then flags_str = flags_str .. " DFS" end
            label = string.format("Channel %d: %d MHz  quality=%d%%%s",
                i + 1, freq_mhz, qual_val, flags_str)
        else
            label = string.format("Channel %d: id=0x%04X  quality=%d%%", i + 1, stored, qual_val)
        end

        local ch_tree = subtree:add(label)

        -- Freq ID with decoded MHz appended
        local freq_item = ch_tree:add_le(f.hd_link_ch_plan_freq_id, payload(freq_off, 2))
        if freq_mhz then
            freq_item:append_text(string.format("  →  %d MHz", freq_mhz))
        end

        ch_tree:add_le(f.hd_link_ch_plan_idx,     payload(idx_off,  1))
        ch_tree:add_le(f.hd_link_ch_plan_quality,  payload(qual_off, 1))

        local flag_tree = ch_tree:add_le(f.hd_link_ch_plan_flags, payload(flag_off, 1))
        flag_tree:add_le(f.hd_link_ch_plan_flag_hop, payload(flag_off, 1))
        flag_tree:add_le(f.hd_link_ch_plan_flag_dfs, payload(flag_off, 1))
    end

    -- Validate total payload length
    if payload:len() ~= CH_PLAN_PAYLOAD_LEN then
        subtree:add_expert_info(PI_PROTOCOL, PI_WARN,
            string.format("HDLnk Channel Plan: payload %d bytes, expected %d",
                payload:len(), CH_PLAN_PAYLOAD_LEN))
    end
end

-- ===========================================================================
-- Registration
-- ===========================================================================
-- HD_LINK_UART_CMD_DISSECT is declared `local` in dji-dumlv1-proto.lua, so we
-- reach it via the global DJI_DUMLv1_CMD_DISSECT[0x09] reference.

if DJI_DUMLv1_CMD_DISSECT then
    local hd_link_dissect = DJI_DUMLv1_CMD_DISSECT[0x09]
    if hd_link_dissect then
        hd_link_dissect[0xF6] = hd_link_channel_plan_dissector
        print("DJI DUML v1 HD Link Extended Dissector loaded — 0xF6 (Channel Plan Push) registered")
    else
        print("Warning: DJI_DUMLv1_CMD_DISSECT[0x09] not found — HD Link ext not loaded")
    end
else
    print("Warning: DJI_DUMLv1_CMD_DISSECT not found — HD Link ext not loaded")
end

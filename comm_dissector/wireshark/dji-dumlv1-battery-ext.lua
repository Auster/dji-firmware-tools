-- DJI DUML v1 Smart Battery Extended Dissector
-- Extension for dji-dumlv1-proto.lua adding detailed battery command parsing
-- Based on analysis of DJIPILOT, fpv_live, and Mobile SDK repositories

local f = DJI_DUMLv1_PROTO.fields

-- Enums for Battery commands

BATTERY_TYPE_ENUM = {
    [0x00] = "Others",
    [0x51] = "MgBattery",
}

BATTERY_SELF_HEATING_CMD_ENUM = {
    [0x01] = "ON",
    [0x02] = "OFF",
    [0xFF] = "UNKNOWN",
}

BATTERY_REARRANGE_TYPE_ENUM = {
    [0x00] = "None",
    [0x01] = "PlugOut",
    [0x02] = "Switch",
    [0x03] = "Move",
}

BATTERY_MULTI_DATA_TYPE_ENUM = {
    [0x00] = "IOC/Current",
    [0x01] = "Voltage",
}

BATTERY_AUTH_TYPE_ENUM = {
    [0x00] = "Random",
    [0x01] = "Known",
}

-- ProtoField definitions for Smart Battery commands

-- Common fields
f.battery_result = ProtoField.uint8("dji_dumlv1.battery_result", "Result", base.HEX)
f.battery_index = ProtoField.uint8("dji_dumlv1.battery_index", "Battery Index", base.DEC)

-- GetStaticData (0x01)
f.battery_design_capacity = ProtoField.uint32("dji_dumlv1.battery_design_capacity", "Design Capacity", base.DEC, nil, nil, "mAh")
f.battery_cycle_count = ProtoField.uint16("dji_dumlv1.battery_cycle_count", "Cycle Count", base.DEC)
f.battery_design_voltage = ProtoField.uint32("dji_dumlv1.battery_design_voltage", "Design Voltage", base.DEC, nil, nil, "mV")
f.battery_prod_date = ProtoField.uint16("dji_dumlv1.battery_prod_date", "Production Date Raw", base.HEX)
f.battery_prod_date_str = ProtoField.string("dji_dumlv1.battery_prod_date_str", "Production Date")
f.battery_serial = ProtoField.uint16("dji_dumlv1.battery_serial", "Serial Number", base.HEX)
f.battery_cell_provider = ProtoField.string("dji_dumlv1.battery_cell_provider", "Cell Provider")
f.battery_board_provider = ProtoField.string("dji_dumlv1.battery_board_provider", "Board Provider")
f.battery_device_name = ProtoField.string("dji_dumlv1.battery_device_name", "Device Name")
f.battery_loader_version = ProtoField.bytes("dji_dumlv1.battery_loader_version", "Loader Version", base.SPACE)
f.battery_app_version = ProtoField.bytes("dji_dumlv1.battery_app_version", "App Version", base.SPACE)
f.battery_soh = ProtoField.uint8("dji_dumlv1.battery_soh", "State of Health", base.DEC, nil, nil, "%")
f.battery_type = ProtoField.uint8("dji_dumlv1.battery_type", "Battery Type", base.HEX, BATTERY_TYPE_ENUM)

-- GetPushDynamicData (0x02)
f.battery_pack_voltage = ProtoField.uint32("dji_dumlv1.battery_pack_voltage", "Pack Voltage", base.DEC, nil, nil, "mV")
f.battery_current = ProtoField.int32("dji_dumlv1.battery_current", "Current", base.DEC, nil, nil, "mA")
f.battery_full_capacity = ProtoField.uint32("dji_dumlv1.battery_full_capacity", "Full Capacity", base.DEC, nil, nil, "mAh")
f.battery_remaining_capacity = ProtoField.uint32("dji_dumlv1.battery_remaining_capacity", "Remaining Capacity", base.DEC, nil, nil, "mAh")
f.battery_temperature = ProtoField.int16("dji_dumlv1.battery_temperature", "Temperature", base.DEC, nil, nil, "°C x 100")
f.battery_cell_count = ProtoField.uint8("dji_dumlv1.battery_cell_count", "Cell Count", base.DEC)
f.battery_soc = ProtoField.uint8("dji_dumlv1.battery_soc", "State of Charge", base.DEC, nil, nil, "%")
f.battery_status_flags = ProtoField.uint64("dji_dumlv1.battery_status_flags", "Status Flags", base.HEX)
f.battery_soh_state = ProtoField.uint8("dji_dumlv1.battery_soh_state", "SOH State", base.HEX)
f.battery_cycle_limit = ProtoField.uint8("dji_dumlv1.battery_cycle_limit", "Cycle Limit", base.DEC)
f.battery_embed_status = ProtoField.uint16("dji_dumlv1.battery_embed_status", "Embed Status", base.HEX)
f.battery_heat_state = ProtoField.uint16("dji_dumlv1.battery_heat_state", "Heat State", base.DEC, nil, nil, "mW")

-- GetPushCellVoltage (0x03)
f.battery_cell_voltage = ProtoField.uint16("dji_dumlv1.battery_cell_voltage", "Cell Voltage", base.DEC, nil, nil, "mV")

-- GetBarCode (0x04)
f.battery_barcode_len = ProtoField.uint8("dji_dumlv1.battery_barcode_len", "Barcode Length", base.DEC)
f.battery_barcode = ProtoField.string("dji_dumlv1.battery_barcode", "Barcode")

-- GetHistory (0x05)
f.battery_history_value = ProtoField.uint32("dji_dumlv1.battery_history_value", "History Value", base.DEC)

-- GetSetSelfDischargeDays (0x11)
f.battery_discharge_type = ProtoField.uint8("dji_dumlv1.battery_discharge_type", "Type", base.DEC, {[0]="Get", [1]="Set"})
f.battery_discharge_days = ProtoField.uint8("dji_dumlv1.battery_discharge_days", "Self-Discharge Days", base.DEC)

-- ForceShutDown/StartUp magic
f.battery_magic = ProtoField.bytes("dji_dumlv1.battery_magic", "Magic Sequence", base.SPACE)

-- GetPair (0x15) / SetPair (0x16)
f.battery_pair_checksum_len = ProtoField.uint8("dji_dumlv1.battery_pair_checksum_len", "Checksum Length", base.DEC)
f.battery_pair_checksum = ProtoField.bytes("dji_dumlv1.battery_pair_checksum", "Checksum", base.SPACE)

-- DataRecordControl (0x22)
f.battery_record_ctrl = ProtoField.uint8("dji_dumlv1.battery_record_ctrl", "Control", base.DEC, {[0]="Stop", [1]="Start"})

-- Authentication (0x23)
f.battery_auth_type = ProtoField.uint8("dji_dumlv1.battery_auth_type", "Auth Type", base.HEX, BATTERY_AUTH_TYPE_ENUM)
f.battery_auth_data = ProtoField.bytes("dji_dumlv1.battery_auth_data", "Auth Data", base.SPACE)
f.battery_is_random = ProtoField.uint8("dji_dumlv1.battery_is_random", "Is Random", base.DEC, {[0]="No", [1]="Yes"})

-- GetPushReArrangement (0x31)
f.battery_rearrange_type = ProtoField.uint8("dji_dumlv1.battery_rearrange_type", "Arrangement Type", base.HEX, BATTERY_REARRANGE_TYPE_ENUM)
f.battery_rearrange_src = ProtoField.uint8("dji_dumlv1.battery_rearrange_src", "Source Index", base.DEC)
f.battery_rearrange_dst = ProtoField.uint8("dji_dumlv1.battery_rearrange_dst", "Destination Index", base.DEC)

-- GetMultBatteryInfo (0x32)
f.battery_multi_data_type = ProtoField.uint8("dji_dumlv1.battery_multi_data_type", "Data Type", base.HEX, BATTERY_MULTI_DATA_TYPE_ENUM)
f.battery_multi_count = ProtoField.uint8("dji_dumlv1.battery_multi_count", "Battery Count", base.DEC)
f.battery_multi_value = ProtoField.uint32("dji_dumlv1.battery_multi_value", "Value", base.DEC)

-- SelfHeatingControl (0x33)
f.battery_heating_cmd = ProtoField.uint8("dji_dumlv1.battery_heating_cmd", "Command", base.HEX, BATTERY_SELF_HEATING_CMD_ENUM)

-- SetLEDsSetting (0xFF)
f.battery_led_flags = ProtoField.uint8("dji_dumlv1.battery_led_flags", "LED Flags", base.HEX)

-- Push request fields
f.battery_request_push = ProtoField.uint8("dji_dumlv1.battery_request_push", "Request Push", base.DEC, {[0]="Stop", [1]="Start"})
f.battery_continue_push = ProtoField.uint8("dji_dumlv1.battery_continue_push", "Continue Push", base.DEC, {[0]="Stop", [1]="Continue"})
f.battery_push_freq = ProtoField.uint8("dji_dumlv1.battery_push_freq", "Push Frequency", base.DEC)

-- Dissector functions

-- 0x01: GetStaticData
local function battery_get_static_data_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 0
    local payload_len = buffer:len()

    if payload_len >= 1 then
        subtree:add_le(f.battery_index, buffer(offset, 1))
        offset = offset + 1
    end

    -- Response has more data
    if payload_len >= 40 then
        subtree:add_le(f.battery_result, buffer(0, 1))
        offset = 2

        subtree:add_le(f.battery_design_capacity, buffer(offset, 4))
        offset = offset + 4

        subtree:add_le(f.battery_cycle_count, buffer(offset, 2))
        offset = offset + 2

        subtree:add_le(f.battery_design_voltage, buffer(offset, 4))
        offset = offset + 4

        -- Production date (packed format)
        local date_raw = buffer(offset, 2):le_uint()
        local year = bit32.rshift(date_raw, 9) + 1980
        local month = bit32.band(bit32.rshift(date_raw, 5), 0x0F)
        local day = bit32.band(date_raw, 0x1F)
        local date_str = string.format("%02d/%02d/%04d", day, month, year)
        subtree:add(f.battery_prod_date_str, date_str)
        offset = offset + 2

        subtree:add_le(f.battery_serial, buffer(offset, 2))
        offset = offset + 2

        if payload_len > offset + 5 then
            subtree:add(f.battery_cell_provider, buffer(offset, 5))
            offset = offset + 8  -- 5 used + 3 reserved
        end

        if payload_len > offset + 5 then
            subtree:add(f.battery_board_provider, buffer(offset, 5))
            offset = offset + 5
        end

        if payload_len > offset + 5 then
            subtree:add(f.battery_device_name, buffer(offset, 5))
            offset = offset + 5
        end

        if payload_len > offset + 4 then
            subtree:add(f.battery_loader_version, buffer(offset, 4))
            offset = offset + 4
        end

        if payload_len > offset + 4 then
            subtree:add(f.battery_app_version, buffer(offset, 4))
            offset = offset + 4
        end

        if payload_len > offset then
            subtree:add_le(f.battery_soh, buffer(offset, 1))
            offset = offset + 1
        end

        if payload_len > offset then
            subtree:add_le(f.battery_type, buffer(offset, 1))
        end
    end
end

-- 0x02: GetPushDynamicData
local function battery_get_push_dynamic_data_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 0
    local payload_len = buffer:len()

    -- Request format (4 bytes)
    if payload_len == 4 then
        subtree:add_le(f.battery_index, buffer(offset, 1))
        offset = offset + 1
        subtree:add_le(f.battery_request_push, buffer(offset, 1))
        offset = offset + 1
        subtree:add_le(f.battery_continue_push, buffer(offset, 1))
        offset = offset + 1
        subtree:add_le(f.battery_push_freq, buffer(offset, 1))
        return
    end

    -- Response/Push format
    if payload_len >= 25 then
        subtree:add_le(f.battery_result, buffer(offset, 1))
        offset = offset + 1

        subtree:add_le(f.battery_index, buffer(offset, 1))
        offset = offset + 1

        -- Skip reserved bytes
        offset = offset + 3

        subtree:add_le(f.battery_pack_voltage, buffer(offset, 4))
        offset = offset + 4

        subtree:add_le(f.battery_current, buffer(offset, 4))
        offset = offset + 4

        subtree:add_le(f.battery_full_capacity, buffer(offset, 4))
        offset = offset + 4

        subtree:add_le(f.battery_remaining_capacity, buffer(offset, 4))
        offset = offset + 4

        subtree:add_le(f.battery_temperature, buffer(offset, 2))
        offset = offset + 2

        subtree:add_le(f.battery_cell_count, buffer(offset, 1))
        offset = offset + 1

        subtree:add_le(f.battery_soc, buffer(offset, 1))
        offset = offset + 1

        if payload_len > offset + 8 then
            subtree:add_le(f.battery_status_flags, buffer(offset, 8))
            offset = offset + 8
        end

        if payload_len > offset then
            subtree:add_le(f.battery_soh_state, buffer(offset, 1))
            offset = offset + 1
        end

        if payload_len > offset then
            local cycle_limit_raw = buffer(offset, 1):uint()
            local cycle_limit = bit32.band(cycle_limit_raw, 0x3F) * 10
            subtree:add(f.battery_cycle_limit, cycle_limit):append_text(" (raw: " .. cycle_limit_raw .. ")")
            offset = offset + 1
        end

        -- Skip to embed status
        offset = offset + 1

        if payload_len > offset + 2 then
            subtree:add_le(f.battery_embed_status, buffer(offset, 2))
            offset = offset + 2
        end

        -- Skip version byte
        offset = offset + 1

        if payload_len > offset + 2 then
            subtree:add_le(f.battery_heat_state, buffer(offset, 2))
        end
    end
end

-- 0x03: GetPushCellVoltage
local function battery_get_push_cell_voltage_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 0
    local payload_len = buffer:len()

    -- Request format (4 bytes)
    if payload_len == 4 then
        subtree:add_le(f.battery_index, buffer(offset, 1))
        offset = offset + 1
        subtree:add_le(f.battery_request_push, buffer(offset, 1))
        offset = offset + 1
        subtree:add_le(f.battery_continue_push, buffer(offset, 1))
        offset = offset + 1
        subtree:add_le(f.battery_push_freq, buffer(offset, 1))
        return
    end

    -- Response format
    if payload_len >= 3 then
        subtree:add_le(f.battery_result, buffer(offset, 1))
        offset = offset + 1

        subtree:add_le(f.battery_index, buffer(offset, 1))
        offset = offset + 1

        local cell_count = buffer(offset, 1):uint()
        subtree:add_le(f.battery_cell_count, buffer(offset, 1))
        offset = offset + 1

        for i = 1, cell_count do
            if offset + 2 <= payload_len then
                subtree:add_le(f.battery_cell_voltage, buffer(offset, 2)):append_text(" (Cell " .. i .. ")")
                offset = offset + 2
            end
        end
    end
end

-- 0x04: GetBarCode
local function battery_get_barcode_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 0
    local payload_len = buffer:len()

    if payload_len == 1 then
        -- Request
        subtree:add_le(f.battery_index, buffer(offset, 1))
        return
    end

    -- Response
    if payload_len >= 3 then
        subtree:add_le(f.battery_result, buffer(offset, 1))
        offset = offset + 1

        subtree:add_le(f.battery_index, buffer(offset, 1))
        offset = offset + 1

        local barcode_len = buffer(offset, 1):uint()
        subtree:add_le(f.battery_barcode_len, buffer(offset, 1))
        offset = offset + 1

        if payload_len > offset and barcode_len > 0 then
            local actual_len = math.min(barcode_len, payload_len - offset)
            subtree:add(f.battery_barcode, buffer(offset, actual_len))
        end
    end
end

-- 0x05: GetHistory
local function battery_get_history_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 0
    local payload_len = buffer:len()

    if payload_len == 1 then
        -- Request
        subtree:add_le(f.battery_index, buffer(offset, 1))
        return
    end

    -- Response
    if payload_len >= 2 then
        subtree:add_le(f.battery_result, buffer(offset, 1))
        offset = offset + 1

        subtree:add_le(f.battery_index, buffer(offset, 1))
        offset = offset + 1

        local entry = 1
        while offset + 4 <= payload_len do
            subtree:add_le(f.battery_history_value, buffer(offset, 4)):append_text(" (Entry " .. entry .. ")")
            offset = offset + 4
            entry = entry + 1
        end
    end
end

-- 0x11: GetSetSelfDischargeDays
local function battery_self_discharge_days_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 0
    local payload_len = buffer:len()

    if payload_len >= 2 then
        subtree:add_le(f.battery_index, buffer(offset, 1))
        offset = offset + 1

        subtree:add_le(f.battery_discharge_type, buffer(offset, 1))
        offset = offset + 1

        if payload_len > offset then
            subtree:add_le(f.battery_discharge_days, buffer(offset, 1))
        end
    end
end

-- 0x12: ShutDown
local function battery_shutdown_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 0
    local payload_len = buffer:len()

    if payload_len >= 1 then
        subtree:add_le(f.battery_index, buffer(offset, 1))
        offset = offset + 1
    end

    if payload_len >= 2 then
        subtree:add_le(f.battery_result, buffer(offset, 1))
    end
end

-- 0x13: ForceShutDown
local function battery_force_shutdown_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 0
    local payload_len = buffer:len()

    if payload_len >= 1 then
        subtree:add_le(f.battery_index, buffer(offset, 1))
        offset = offset + 1
    end

    -- Magic sequence: 46 4E 28 19 EF BE AD DE
    if payload_len >= 9 then
        subtree:add(f.battery_magic, buffer(offset, 8))
    elseif payload_len == 2 then
        -- Response
        subtree:add_le(f.battery_result, buffer(offset, 1))
    end
end

-- 0x14: StartUp
local function battery_startup_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 0
    local payload_len = buffer:len()

    if payload_len >= 1 then
        subtree:add_le(f.battery_index, buffer(offset, 1))
        offset = offset + 1
    end

    -- Magic sequence: EF BE AD DE 46 4E 28 19
    if payload_len >= 9 then
        subtree:add(f.battery_magic, buffer(offset, 8))
    elseif payload_len == 2 then
        -- Response
        subtree:add_le(f.battery_result, buffer(offset, 1))
    end
end

-- 0x15: GetPair
local function battery_get_pair_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 0
    local payload_len = buffer:len()

    if payload_len == 1 then
        -- Request
        subtree:add_le(f.battery_index, buffer(offset, 1))
        return
    end

    -- Response
    if payload_len >= 3 then
        subtree:add_le(f.battery_result, buffer(offset, 1))
        offset = offset + 1

        -- Reserved byte
        offset = offset + 1

        local checksum_len = buffer(offset, 1):uint()
        subtree:add_le(f.battery_pair_checksum_len, buffer(offset, 1))
        offset = offset + 1

        if checksum_len > 0 and payload_len > offset then
            local actual_len = math.min(checksum_len, payload_len - offset)
            subtree:add(f.battery_pair_checksum, buffer(offset, actual_len))
        end
    end
end

-- 0x16: SetPair
local function battery_set_pair_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 0
    local payload_len = buffer:len()

    if payload_len >= 2 then
        subtree:add_le(f.battery_index, buffer(offset, 1))
        offset = offset + 1

        local checksum_len = buffer(offset, 1):uint()
        subtree:add_le(f.battery_pair_checksum_len, buffer(offset, 1))
        offset = offset + 1

        if checksum_len > 0 and payload_len > offset then
            local actual_len = math.min(checksum_len, payload_len - offset)
            subtree:add(f.battery_pair_checksum, buffer(offset, actual_len))
        end
    elseif payload_len == 1 then
        -- Response
        subtree:add_le(f.battery_result, buffer(offset, 1))
    end
end

-- 0x22: DataRecordControl
local function battery_data_record_control_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 0
    local payload_len = buffer:len()

    if payload_len >= 2 then
        subtree:add_le(f.battery_index, buffer(offset, 1))
        offset = offset + 1

        subtree:add_le(f.battery_record_ctrl, buffer(offset, 1))
    elseif payload_len == 1 then
        subtree:add_le(f.battery_result, buffer(offset, 1))
    end
end

-- 0x23: Authentication
local function battery_authentication_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 0
    local payload_len = buffer:len()

    if payload_len >= 22 then
        -- Request
        subtree:add_le(f.battery_index, buffer(offset, 1))
        offset = offset + 1

        subtree:add_le(f.battery_auth_type, buffer(offset, 1))
        offset = offset + 1

        subtree:add(f.battery_auth_data, buffer(offset, 20))
    elseif payload_len >= 3 then
        -- Response
        subtree:add_le(f.battery_result, buffer(offset, 1))
        offset = offset + 1

        subtree:add_le(f.battery_index, buffer(offset, 1))
        offset = offset + 1

        subtree:add_le(f.battery_is_random, buffer(offset, 1))
    end
end

-- 0x31: GetPushReArrangement
local function battery_rearrangement_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 0
    local payload_len = buffer:len()

    -- Push data: 6 x 3-byte arrangements
    local slot = 1
    while offset + 3 <= payload_len and slot <= 6 do
        local slot_tree = subtree:add(buffer(offset, 3), "Slot " .. slot)

        slot_tree:add_le(f.battery_rearrange_type, buffer(offset, 1))
        offset = offset + 1

        slot_tree:add_le(f.battery_rearrange_src, buffer(offset, 1))
        offset = offset + 1

        slot_tree:add_le(f.battery_rearrange_dst, buffer(offset, 1))
        offset = offset + 1

        slot = slot + 1
    end
end

-- 0x32: GetMultBatteryInfo
local function battery_multi_info_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 0
    local payload_len = buffer:len()

    if payload_len >= 3 then
        subtree:add_le(f.battery_result, buffer(offset, 1))
        offset = offset + 1

        subtree:add_le(f.battery_multi_data_type, buffer(offset, 1))
        offset = offset + 1

        local batt_count = buffer(offset, 1):uint()
        subtree:add_le(f.battery_multi_count, buffer(offset, 1))
        offset = offset + 1

        for i = 1, batt_count do
            if offset + 4 <= payload_len then
                subtree:add_le(f.battery_multi_value, buffer(offset, 4)):append_text(" (Battery " .. i .. ")")
                offset = offset + 4
            end
        end
    end
end

-- 0x33: SelfHeatingControl
local function battery_self_heating_control_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 0
    local payload_len = buffer:len()

    if payload_len >= 1 then
        subtree:add_le(f.battery_heating_cmd, buffer(offset, 1))
    end
end

-- 0xFF: SetLEDsSetting
local function battery_set_leds_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 0
    local payload_len = buffer:len()

    if payload_len >= 2 then
        subtree:add_le(f.battery_index, buffer(offset, 1))
        offset = offset + 1

        subtree:add_le(f.battery_led_flags, buffer(offset, 1))
    elseif payload_len == 1 then
        subtree:add_le(f.battery_result, buffer(offset, 1))
    end
end

-- Command dispatch table for Smart Battery (CmdSet 0x0D)
local SMART_BATTERY_DISSECTORS = {
    [0x01] = battery_get_static_data_dissector,
    [0x02] = battery_get_push_dynamic_data_dissector,
    [0x03] = battery_get_push_cell_voltage_dissector,
    [0x04] = battery_get_barcode_dissector,
    [0x05] = battery_get_history_dissector,
    [0x11] = battery_self_discharge_days_dissector,
    [0x12] = battery_shutdown_dissector,
    [0x13] = battery_force_shutdown_dissector,
    [0x14] = battery_startup_dissector,
    [0x15] = battery_get_pair_dissector,
    [0x16] = battery_set_pair_dissector,
    [0x22] = battery_data_record_control_dissector,
    [0x23] = battery_authentication_dissector,
    [0x31] = battery_rearrangement_dissector,
    [0x32] = battery_multi_info_dissector,
    [0x33] = battery_self_heating_control_dissector,
    [0xFF] = battery_set_leds_dissector,
}

-- Extended command name table
local SMART_BATTERY_CMDS_EXT = {
    [0x01] = 'Get Static Data',
    [0x02] = 'Get/Push Dynamic Data',
    [0x03] = 'Get/Push Cell Voltage',
    [0x04] = 'Get Barcode',
    [0x05] = 'Get History',
    [0x11] = 'Get/Set Self-Discharge Days',
    [0x12] = 'Shutdown',
    [0x13] = 'Force Shutdown',
    [0x14] = 'Startup',
    [0x15] = 'Get Pair',
    [0x16] = 'Set Pair',
    [0x22] = 'Data Record Control',
    [0x23] = 'Authentication',
    [0x31] = 'Get/Push Re-Arrangement',
    [0x32] = 'Get Multi-Battery Info',
    [0x33] = 'Self-Heating Control',
    [0xFF] = 'Set LEDs Setting',
}

-- Merge extended command names into main table
if BATTERY_UART_CMD_TEXT then
    for k, v in pairs(SMART_BATTERY_CMDS_EXT) do
        if BATTERY_UART_CMD_TEXT[k] == nil then
            BATTERY_UART_CMD_TEXT[k] = v
        end
    end
end

-- Register extended dissectors to the main BATTERY_UART_CMD_DISSECT table
-- This table is defined in dji-dumlv1-proto.lua and used for CmdSet 0x0D

if BATTERY_UART_CMD_DISSECT then
    -- Only add dissectors for commands not already defined in the main file
    -- Main file has: 0x01, 0x02, 0x03, 0x04, 0x31
    -- We add extended versions and new commands

    -- Self-discharge and shutdown commands
    BATTERY_UART_CMD_DISSECT[0x11] = battery_self_discharge_days_dissector
    BATTERY_UART_CMD_DISSECT[0x12] = battery_shutdown_dissector
    BATTERY_UART_CMD_DISSECT[0x13] = battery_force_shutdown_dissector
    BATTERY_UART_CMD_DISSECT[0x14] = battery_startup_dissector

    -- Pairing commands
    BATTERY_UART_CMD_DISSECT[0x15] = battery_get_pair_dissector
    BATTERY_UART_CMD_DISSECT[0x16] = battery_set_pair_dissector

    -- Data recording and authentication
    BATTERY_UART_CMD_DISSECT[0x22] = battery_data_record_control_dissector
    BATTERY_UART_CMD_DISSECT[0x23] = battery_authentication_dissector

    -- Multi-battery and heating
    BATTERY_UART_CMD_DISSECT[0x32] = battery_multi_info_dissector
    BATTERY_UART_CMD_DISSECT[0x33] = battery_self_heating_control_dissector

    -- LED control
    BATTERY_UART_CMD_DISSECT[0xFF] = battery_set_leds_dissector

    print("DJI DUML v1 Smart Battery Extended Dissector loaded - 11 new commands registered")
else
    print("Warning: BATTERY_UART_CMD_DISSECT not found - battery extension not loaded")
end

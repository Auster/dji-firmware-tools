-- Extended definitions for DJI DUMLv1 protocol dissector
-- Additional dissectors for command set 0x04 - Gimbal
-- Based on reverse engineering from DJIPILOT_src
--
-- This file extends dji-dumlv1-gimbal.lua with additional dissectors
-- Load after the main gimbal dissector

local f = DJI_DUMLv1_PROTO.fields
local enums = {}

--------------------------------------------------------------------------------
-- Extended enums based on DJIPILOT_src research
--------------------------------------------------------------------------------

-- Gimbal Mode (DataGimbalControl.java)
enums.GIMBAL_MODE_ENUM = {
    [0x00] = 'Yaw Follow',
    [0x01] = 'Yaw No Follow (FPV)',
    [0x02] = 'FPV Mode',
    [0x03] = 'Other/Unknown',
}

-- Return Center Command (DataGimbalNewResetAndSetMode.java)
enums.GIMBAL_RETURN_CENTER_ENUM = {
    [0x00] = 'Invalid',
    [0x01] = 'Pitch Center',
    [0x02] = 'Pitch Up/Down',
    [0x03] = 'Yaw Center',
    [0x04] = 'Pitch+Yaw Center',
    [0x05] = 'Pitch Up/Down + Yaw Center',
}

-- Fine-tune Axis (DataGimbalRollFinetune.java)
enums.GIMBAL_FINETUNE_AXIS_ENUM = {
    [0x00] = 'Roll',
    [0x02] = 'Pitch',
    [0x04] = 'Yaw',
}

-- Calibration Status
enums.GIMBAL_CALIB_STATUS_ENUM = {
    [0x00] = 'Idle',
    [0x01] = 'In Progress',
    [0x02] = 'Succeeded',
    [0x03] = 'Failed',
    [0x04] = 'Timeout',
}

-- Handheld Stick State
enums.GIMBAL_STICK_STATE_ENUM = {
    [0x00] = 'Centered',
    [0x01] = 'Left',
    [0x02] = 'Right',
    [0x03] = 'Up',
    [0x04] = 'Down',
    [0x05] = 'Double Click',
    [0x06] = 'Triple Click',
}

--------------------------------------------------------------------------------
-- Extended Field definitions for gimbal commands
--------------------------------------------------------------------------------

-- Gimbal New Reset and Set Mode (0x2D / 0x4C)
f.gimbal_return_center_cmd = ProtoField.uint8 ("dji_dumlv1.gimbal_return_center_cmd", "Return Center Command", base.HEX, enums.GIMBAL_RETURN_CENTER_ENUM)
f.gimbal_new_mode = ProtoField.uint8 ("dji_dumlv1.gimbal_new_mode", "Gimbal Mode", base.HEX, enums.GIMBAL_MODE_ENUM)

-- Gimbal Fine-tune (0x07) - Extended with axis enum
f.gimbal_finetune_axis = ProtoField.uint8 ("dji_dumlv1.gimbal_finetune_axis", "Fine-tune Axis", base.HEX, enums.GIMBAL_FINETUNE_AXIS_ENUM)
f.gimbal_finetune_value = ProtoField.int8 ("dji_dumlv1.gimbal_finetune_value", "Fine-tune Value", base.DEC)

-- Gimbal Speed Control Extended (0x0C) - DataGimbalSpeedControl.java
f.gimbal_speed_yaw = ProtoField.int16 ("dji_dumlv1.gimbal_speed_yaw", "Yaw Speed", base.DEC)
f.gimbal_speed_roll = ProtoField.int16 ("dji_dumlv1.gimbal_speed_roll", "Roll Speed", base.DEC)
f.gimbal_speed_pitch = ProtoField.int16 ("dji_dumlv1.gimbal_speed_pitch", "Pitch Speed", base.DEC)
f.gimbal_speed_permission = ProtoField.uint8 ("dji_dumlv1.gimbal_speed_permission", "Permission", base.HEX)
  f.gimbal_speed_multi_ctrl = ProtoField.uint8 ("dji_dumlv1.gimbal_speed_multi_ctrl", "Multi Control", base.HEX, nil, 0x01)

-- Gimbal Angle Control Extended (0x0A) - DataGimbalSetAngle.java
f.gimbal_angle_yaw = ProtoField.int16 ("dji_dumlv1.gimbal_angle_yaw", "Yaw Angle (deg*10)", base.DEC)
f.gimbal_angle_roll = ProtoField.int16 ("dji_dumlv1.gimbal_angle_roll", "Roll Angle (deg*10)", base.DEC)
f.gimbal_angle_pitch = ProtoField.int16 ("dji_dumlv1.gimbal_angle_pitch", "Pitch Angle (deg*10)", base.DEC)
f.gimbal_angle_flags = ProtoField.uint8 ("dji_dumlv1.gimbal_angle_flags", "Angle Flags", base.HEX)
  f.gimbal_angle_yaw_invalid = ProtoField.uint8 ("dji_dumlv1.gimbal_angle_yaw_invalid", "Yaw Invalid", base.HEX, nil, 0x01)
  f.gimbal_angle_roll_invalid = ProtoField.uint8 ("dji_dumlv1.gimbal_angle_roll_invalid", "Roll Invalid", base.HEX, nil, 0x02)
  f.gimbal_angle_pitch_invalid = ProtoField.uint8 ("dji_dumlv1.gimbal_angle_pitch_invalid", "Pitch Invalid", base.HEX, nil, 0x04)

-- Gimbal Timelapse Parameters (0x37)
f.gimbal_timelapse_duration = ProtoField.uint32 ("dji_dumlv1.gimbal_timelapse_duration", "Duration (ms)", base.DEC)
f.gimbal_timelapse_interval = ProtoField.uint32 ("dji_dumlv1.gimbal_timelapse_interval", "Interval (ms)", base.DEC)
f.gimbal_timelapse_start_yaw = ProtoField.int16 ("dji_dumlv1.gimbal_timelapse_start_yaw", "Start Yaw (deg*10)", base.DEC)
f.gimbal_timelapse_start_pitch = ProtoField.int16 ("dji_dumlv1.gimbal_timelapse_start_pitch", "Start Pitch (deg*10)", base.DEC)
f.gimbal_timelapse_end_yaw = ProtoField.int16 ("dji_dumlv1.gimbal_timelapse_end_yaw", "End Yaw (deg*10)", base.DEC)
f.gimbal_timelapse_end_pitch = ProtoField.int16 ("dji_dumlv1.gimbal_timelapse_end_pitch", "End Pitch (deg*10)", base.DEC)

-- Gimbal Timelapse Status (0x38)
f.gimbal_timelapse_status = ProtoField.uint8 ("dji_dumlv1.gimbal_timelapse_status", "Timelapse Status", base.HEX, {
    [0x00] = 'Idle',
    [0x01] = 'Running',
    [0x02] = 'Paused',
    [0x03] = 'Completed',
    [0x04] = 'Error',
})
f.gimbal_timelapse_progress = ProtoField.uint8 ("dji_dumlv1.gimbal_timelapse_progress", "Progress (%)", base.DEC)

-- Gimbal Lock/Release (0x39, 0x3A)
f.gimbal_lock_state = ProtoField.uint8 ("dji_dumlv1.gimbal_lock_state", "Lock State", base.HEX, {[0]='Unlocked', [1]='Locked'})

-- Gimbal Temperature (0x45)
f.gimbal_temperature = ProtoField.int16 ("dji_dumlv1.gimbal_temperature", "Temperature (C*10)", base.DEC)

-- Gimbal Handle Parameters (0x34, 0x36)
f.gimbal_handle_sensitivity = ProtoField.uint8 ("dji_dumlv1.gimbal_handle_sensitivity", "Sensitivity", base.DEC)
f.gimbal_handle_deadband = ProtoField.uint8 ("dji_dumlv1.gimbal_handle_deadband", "Deadband", base.DEC)
f.gimbal_handle_speed_limit = ProtoField.uint8 ("dji_dumlv1.gimbal_handle_speed_limit", "Speed Limit", base.DEC)
f.gimbal_handle_smoothness = ProtoField.uint8 ("dji_dumlv1.gimbal_handle_smoothness", "Smoothness", base.DEC)

-- Handheld Stick State (0x57)
f.gimbal_stick_horizontal = ProtoField.uint8 ("dji_dumlv1.gimbal_stick_horizontal", "Horizontal State", base.HEX, enums.GIMBAL_STICK_STATE_ENUM)
f.gimbal_stick_vertical = ProtoField.uint8 ("dji_dumlv1.gimbal_stick_vertical", "Vertical State", base.HEX, enums.GIMBAL_STICK_STATE_ENUM)
f.gimbal_stick_press = ProtoField.uint8 ("dji_dumlv1.gimbal_stick_press", "Press State", base.HEX)

-- Handheld Stick Control Enable (0x58)
f.gimbal_stick_ctrl_enable = ProtoField.uint8 ("dji_dumlv1.gimbal_stick_ctrl_enable", "Stick Control Enable", base.HEX, {[0]='Disabled', [1]='Enabled'})

-- Gimbal Auto Calibration Status (0x30) - extended
f.gimbal_calib_status = ProtoField.uint8 ("dji_dumlv1.gimbal_calib_status", "Calibration Status", base.HEX, enums.GIMBAL_CALIB_STATUS_ENUM)
f.gimbal_calib_progress = ProtoField.uint8 ("dji_dumlv1.gimbal_calib_progress", "Calibration Progress (%)", base.DEC)

-- Robin/Ronin Battery Info (0x33)
f.gimbal_robin_batt_percent = ProtoField.uint8 ("dji_dumlv1.gimbal_robin_batt_percent", "Battery Percent", base.DEC)
f.gimbal_robin_batt_voltage = ProtoField.uint16 ("dji_dumlv1.gimbal_robin_batt_voltage", "Battery Voltage (mV)", base.DEC)
f.gimbal_robin_batt_current = ProtoField.int16 ("dji_dumlv1.gimbal_robin_batt_current", "Battery Current (mA)", base.DEC)
f.gimbal_robin_batt_temp = ProtoField.int8 ("dji_dumlv1.gimbal_robin_batt_temp", "Battery Temp (C)", base.DEC)

-- Gimbal Tutorial (0x2B, 0x2C)
f.gimbal_tutorial_step = ProtoField.uint8 ("dji_dumlv1.gimbal_tutorial_step", "Tutorial Step", base.DEC)
f.gimbal_tutorial_status = ProtoField.uint8 ("dji_dumlv1.gimbal_tutorial_status", "Tutorial Status", base.HEX, {
    [0x00] = 'Not Started',
    [0x01] = 'In Progress',
    [0x02] = 'Completed',
    [0x03] = 'Skipped',
})

-- Gimbal Abnormal Status (0x27)
f.gimbal_abnormal_flags = ProtoField.uint16 ("dji_dumlv1.gimbal_abnormal_flags", "Abnormal Flags", base.HEX)
  f.gimbal_abnormal_motor_stuck = ProtoField.uint16 ("dji_dumlv1.gimbal_abnormal_motor_stuck", "Motor Stuck", base.HEX, nil, 0x0001)
  f.gimbal_abnormal_motor_protect = ProtoField.uint16 ("dji_dumlv1.gimbal_abnormal_motor_protect", "Motor Protected", base.HEX, nil, 0x0002)
  f.gimbal_abnormal_imu_error = ProtoField.uint16 ("dji_dumlv1.gimbal_abnormal_imu_error", "IMU Error", base.HEX, nil, 0x0004)
  f.gimbal_abnormal_gyro_error = ProtoField.uint16 ("dji_dumlv1.gimbal_abnormal_gyro_error", "Gyro Error", base.HEX, nil, 0x0008)
  f.gimbal_abnormal_pitch_limit = ProtoField.uint16 ("dji_dumlv1.gimbal_abnormal_pitch_limit", "Pitch Limit", base.HEX, nil, 0x0010)
  f.gimbal_abnormal_roll_limit = ProtoField.uint16 ("dji_dumlv1.gimbal_abnormal_roll_limit", "Roll Limit", base.HEX, nil, 0x0020)
  f.gimbal_abnormal_yaw_limit = ProtoField.uint16 ("dji_dumlv1.gimbal_abnormal_yaw_limit", "Yaw Limit", base.HEX, nil, 0x0040)

--------------------------------------------------------------------------------
-- Dissector functions for extended gimbal commands
--------------------------------------------------------------------------------

-- Gimbal New Reset and Set Mode Dissector (0x4C)
local function gimbal_reset_set_mode_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 1 then
        subtree:add_le (f.gimbal_return_center_cmd, payload(offset, 1))
        offset = offset + 1
    end

    if payload:len() >= 2 then
        subtree:add_le (f.gimbal_new_mode, payload(offset, 1))
        offset = offset + 1
    end
end

-- Gimbal Fine-tune Extended Dissector (0x07)
local function gimbal_finetune_ext_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 2 then
        subtree:add_le (f.gimbal_finetune_axis, payload(offset, 1))
        offset = offset + 1

        subtree:add_le (f.gimbal_finetune_value, payload(offset, 1))
        offset = offset + 1
    end
end

-- Gimbal Speed Control Extended Dissector (0x0C)
local function gimbal_speed_ctrl_ext_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 7 then
        subtree:add_le (f.gimbal_speed_yaw, payload(offset, 2))
        offset = offset + 2

        subtree:add_le (f.gimbal_speed_roll, payload(offset, 2))
        offset = offset + 2

        subtree:add_le (f.gimbal_speed_pitch, payload(offset, 2))
        offset = offset + 2

        subtree:add_le (f.gimbal_speed_permission, payload(offset, 1))
        subtree:add_le (f.gimbal_speed_multi_ctrl, payload(offset, 1))
        offset = offset + 1
    end
end

-- Gimbal Angle Control Extended Dissector (0x0A)
local function gimbal_angle_ctrl_ext_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 7 then
        subtree:add_le (f.gimbal_angle_yaw, payload(offset, 2))
        offset = offset + 2

        subtree:add_le (f.gimbal_angle_roll, payload(offset, 2))
        offset = offset + 2

        subtree:add_le (f.gimbal_angle_pitch, payload(offset, 2))
        offset = offset + 2

        subtree:add_le (f.gimbal_angle_flags, payload(offset, 1))
        subtree:add_le (f.gimbal_angle_yaw_invalid, payload(offset, 1))
        subtree:add_le (f.gimbal_angle_roll_invalid, payload(offset, 1))
        subtree:add_le (f.gimbal_angle_pitch_invalid, payload(offset, 1))
        offset = offset + 1
    end
end

-- Gimbal Timelapse Parameters Dissector (0x37)
local function gimbal_timelapse_params_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 16 then
        subtree:add_le (f.gimbal_timelapse_duration, payload(offset, 4))
        offset = offset + 4

        subtree:add_le (f.gimbal_timelapse_interval, payload(offset, 4))
        offset = offset + 4

        subtree:add_le (f.gimbal_timelapse_start_yaw, payload(offset, 2))
        offset = offset + 2

        subtree:add_le (f.gimbal_timelapse_start_pitch, payload(offset, 2))
        offset = offset + 2

        subtree:add_le (f.gimbal_timelapse_end_yaw, payload(offset, 2))
        offset = offset + 2

        subtree:add_le (f.gimbal_timelapse_end_pitch, payload(offset, 2))
        offset = offset + 2
    end
end

-- Gimbal Timelapse Status Dissector (0x38)
local function gimbal_timelapse_status_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 2 then
        subtree:add_le (f.gimbal_timelapse_status, payload(offset, 1))
        offset = offset + 1

        subtree:add_le (f.gimbal_timelapse_progress, payload(offset, 1))
        offset = offset + 1
    end
end

-- Gimbal Lock/Release Dissector (0x39, 0x3A)
local function gimbal_lock_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 1 then
        subtree:add_le (f.gimbal_lock_state, payload(offset, 1))
        offset = offset + 1
    end
end

-- Gimbal Temperature Dissector (0x45)
local function gimbal_temperature_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 2 then
        subtree:add_le (f.gimbal_temperature, payload(offset, 2))
        offset = offset + 2
    end
end

-- Gimbal Handle Parameters Dissector (0x34, 0x36)
local function gimbal_handle_params_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 4 then
        subtree:add_le (f.gimbal_handle_sensitivity, payload(offset, 1))
        offset = offset + 1

        subtree:add_le (f.gimbal_handle_deadband, payload(offset, 1))
        offset = offset + 1

        subtree:add_le (f.gimbal_handle_speed_limit, payload(offset, 1))
        offset = offset + 1

        subtree:add_le (f.gimbal_handle_smoothness, payload(offset, 1))
        offset = offset + 1
    end
end

-- Handheld Stick State Dissector (0x57)
local function gimbal_stick_state_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 3 then
        subtree:add_le (f.gimbal_stick_horizontal, payload(offset, 1))
        offset = offset + 1

        subtree:add_le (f.gimbal_stick_vertical, payload(offset, 1))
        offset = offset + 1

        subtree:add_le (f.gimbal_stick_press, payload(offset, 1))
        offset = offset + 1
    end
end

-- Handheld Stick Control Enable Dissector (0x58)
local function gimbal_stick_ctrl_enable_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 1 then
        subtree:add_le (f.gimbal_stick_ctrl_enable, payload(offset, 1))
        offset = offset + 1
    end
end

-- Gimbal Auto Calibration Status Extended Dissector (0x30)
local function gimbal_calib_status_ext_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 2 then
        subtree:add_le (f.gimbal_calib_status, payload(offset, 1))
        offset = offset + 1

        subtree:add_le (f.gimbal_calib_progress, payload(offset, 1))
        offset = offset + 1
    end
end

-- Robin/Ronin Battery Info Dissector (0x33)
local function gimbal_robin_battery_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 6 then
        subtree:add_le (f.gimbal_robin_batt_percent, payload(offset, 1))
        offset = offset + 1

        subtree:add_le (f.gimbal_robin_batt_voltage, payload(offset, 2))
        offset = offset + 2

        subtree:add_le (f.gimbal_robin_batt_current, payload(offset, 2))
        offset = offset + 2

        subtree:add_le (f.gimbal_robin_batt_temp, payload(offset, 1))
        offset = offset + 1
    end
end

-- Gimbal Tutorial Status Dissector (0x2B)
local function gimbal_tutorial_status_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 2 then
        subtree:add_le (f.gimbal_tutorial_step, payload(offset, 1))
        offset = offset + 1

        subtree:add_le (f.gimbal_tutorial_status, payload(offset, 1))
        offset = offset + 1
    end
end

-- Gimbal Tutorial Step Set Dissector (0x2C)
local function gimbal_tutorial_step_set_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 1 then
        subtree:add_le (f.gimbal_tutorial_step, payload(offset, 1))
        offset = offset + 1
    end
end

-- Gimbal Abnormal Status Dissector (0x27)
local function gimbal_abnormal_status_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 2 then
        subtree:add_le (f.gimbal_abnormal_flags, payload(offset, 2))
        subtree:add_le (f.gimbal_abnormal_motor_stuck, payload(offset, 2))
        subtree:add_le (f.gimbal_abnormal_motor_protect, payload(offset, 2))
        subtree:add_le (f.gimbal_abnormal_imu_error, payload(offset, 2))
        subtree:add_le (f.gimbal_abnormal_gyro_error, payload(offset, 2))
        subtree:add_le (f.gimbal_abnormal_pitch_limit, payload(offset, 2))
        subtree:add_le (f.gimbal_abnormal_roll_limit, payload(offset, 2))
        subtree:add_le (f.gimbal_abnormal_yaw_limit, payload(offset, 2))
        offset = offset + 2
    end
end

--------------------------------------------------------------------------------
-- Register extended dissectors to the main GIMBAL_UART_CMD_DISSECT table
--------------------------------------------------------------------------------

if GIMBAL_UART_CMD_DISSECT then
    -- Extended control commands (may override existing ones with better parsing)
    GIMBAL_UART_CMD_DISSECT[0x07] = gimbal_finetune_ext_dissector
    GIMBAL_UART_CMD_DISSECT[0x0A] = gimbal_angle_ctrl_ext_dissector
    GIMBAL_UART_CMD_DISSECT[0x0C] = gimbal_speed_ctrl_ext_dissector

    -- Reset and mode commands
    GIMBAL_UART_CMD_DISSECT[0x4C] = gimbal_reset_set_mode_dissector

    -- Tutorial commands
    GIMBAL_UART_CMD_DISSECT[0x2B] = gimbal_tutorial_status_dissector
    GIMBAL_UART_CMD_DISSECT[0x2C] = gimbal_tutorial_step_set_dissector

    -- Abnormal status
    GIMBAL_UART_CMD_DISSECT[0x27] = gimbal_abnormal_status_dissector

    -- Calibration status (extended)
    GIMBAL_UART_CMD_DISSECT[0x30] = gimbal_calib_status_ext_dissector

    -- Robin/Ronin handheld commands
    GIMBAL_UART_CMD_DISSECT[0x33] = gimbal_robin_battery_dissector
    GIMBAL_UART_CMD_DISSECT[0x34] = gimbal_handle_params_dissector
    GIMBAL_UART_CMD_DISSECT[0x36] = gimbal_handle_params_dissector

    -- Timelapse commands
    GIMBAL_UART_CMD_DISSECT[0x37] = gimbal_timelapse_params_dissector
    GIMBAL_UART_CMD_DISSECT[0x38] = gimbal_timelapse_status_dissector

    -- Lock/Release
    GIMBAL_UART_CMD_DISSECT[0x39] = gimbal_lock_dissector
    GIMBAL_UART_CMD_DISSECT[0x3A] = gimbal_lock_dissector

    -- Temperature
    GIMBAL_UART_CMD_DISSECT[0x45] = gimbal_temperature_dissector

    -- Handheld stick commands
    GIMBAL_UART_CMD_DISSECT[0x57] = gimbal_stick_state_dissector
    GIMBAL_UART_CMD_DISSECT[0x58] = gimbal_stick_ctrl_enable_dissector

    print("DJI DUMLv1 Gimbal Extension: Added 17 new/extended dissectors")
else
    print("Warning: GIMBAL_UART_CMD_DISSECT not found - Gimbal extension not loaded")
end

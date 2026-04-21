-- Extended definitions for DJI DUMLv1 protocol dissector
-- Additional dissectors for command set 0x03 - Flight Control
-- Based on reverse engineering from DJIPILOT_src
--
-- This file extends dji-dumlv1-flyc.lua with additional dissectors
-- Load after the main flyc dissector

local f = DJI_DUMLv1_PROTO.fields
local enums = {}

--------------------------------------------------------------------------------
-- Extended enums based on DJIPILOT_src research
--------------------------------------------------------------------------------

-- Function Control Commands (DataFlycFunctionControl.java)
enums.FLYC_FUNCTION_COMMAND_ENUM = {
    [0x01] = 'Start Motor',
    [0x02] = 'Stop Motor',
    [0x03] = 'Auto Fly',
    [0x04] = 'Auto Landing',
    [0x05] = 'Go Home',
    [0x06] = 'Force Landing',
    [0x07] = 'Force Landing 2',
    [0x08] = 'Enter Manual Mode',
    [0x10] = 'Home Point Now',
    [0x11] = 'Home Point Location',
    [0x12] = 'Home Point Hot',
    [0x20] = 'IOC Open',
    [0x21] = 'IOC Close',
    [0x30] = 'Follow Function Open',
    [0x31] = 'Follow Function Close',
    [0x40] = 'Mass Center Calibration',
    [0x41] = 'Exit Mass Center Calibration',
    [0x50] = 'Pack Mode (Fold Gear)',
    [0x51] = 'Unpack Mode (Unfold Gear)',
    [0x60] = 'Up Deform',
    [0x61] = 'Down Deform',
    [0x62] = 'Stop Deform',
    [0x63] = 'Deform Protection Open',
    [0x64] = 'Deform Protection Close',
    [0x70] = 'Calibration',
    [0x71] = 'Drop Calibration',
    [0x72] = 'Drop Takeoff',
    [0x73] = 'Drop Go Home',
    [0x74] = 'Drop Landing',
    [0x80] = 'Dynamic Home Open',
    [0x81] = 'Dynamic Home Close',
    [0x90] = 'Precision Takeoff',
}

-- Exec Fly Type (DataFlycExecFly.java)
enums.FLYC_EXEC_FLY_TYPE_ENUM = {
    [0x00] = 'Start Fly',
    [0x01] = 'Pause Fly',
    [0x02] = 'Resume Fly',
    [0x03] = 'Auto Landing',
    [0x04] = 'Start Turn',
    [0x05] = 'Enter Signal',
    [0x06] = 'Exit Signal',
}

-- Home Point Type (DataFlycSetHomePoint.java)
enums.FLYC_HOME_POINT_TYPE_ENUM = {
    [0x00] = 'Aircraft',
    [0x01] = 'APP',
    [0x02] = 'RC',
    [0x03] = 'Follow',
}

-- IOC Mode Type
enums.FLYC_IOC_MODE_TYPE_ENUM = {
    [0x00] = 'CourseLock',
    [0x01] = 'HomeLock',
    [0x02] = 'HomePoint',
    [0x03] = 'Unknown3',
}

-- Waypoint Finish Action (DataFlycUploadWayPointMissionMsg.java)
enums.FLYC_WP_FINISH_ACTION_ENUM = {
    [0x00] = 'No Action (Hover)',
    [0x01] = 'Go Home',
    [0x02] = 'Auto Land',
    [0x03] = 'Back to First Waypoint',
    [0x04] = 'Infinite Mode (Repeat)',
}

-- Waypoint Yaw Mode
enums.FLYC_WP_YAW_MODE_ENUM = {
    [0x00] = 'Auto',
    [0x01] = 'Lock',
    [0x02] = 'RC Control',
    [0x03] = 'Waypoint',
}

-- Waypoint Trace Mode
enums.FLYC_WP_TRACE_MODE_ENUM = {
    [0x00] = 'Point to Point',
    [0x01] = 'Coordinated Turn',
}

-- Waypoint Action on RC Loss
enums.FLYC_WP_RC_LOSS_ACTION_ENUM = {
    [0x00] = 'Exit Waypoint',
    [0x01] = 'Continue Waypoint',
}

-- Waypoint Goto First Mode
enums.FLYC_WP_GOTO_FIRST_MODE_ENUM = {
    [0x00] = 'Point to Point',
    [0x01] = 'Safe Alt',
}

-- Navigation Switch Command
enums.FLYC_NAV_SWITCH_CMD_ENUM = {
    [0x01] = 'Open Ground Station',
    [0x02] = 'Close Ground Station',
}

--------------------------------------------------------------------------------
-- Field definitions for extended commands
--------------------------------------------------------------------------------

-- Joystick (0x29) - DataFlycJoystick.java
-- Packet: 17 bytes (flag + roll + pitch + yaw + throttle as floats)
f.flyc_joystick_flag = ProtoField.uint8 ("dji_dumlv1.flyc_joystick_flag", "Control Flag", base.HEX, nil, nil, "Joystick control mode flag")
f.flyc_joystick_roll = ProtoField.float ("dji_dumlv1.flyc_joystick_roll", "Roll", nil, "Roll axis value (-1.0 to 1.0)")
f.flyc_joystick_pitch = ProtoField.float ("dji_dumlv1.flyc_joystick_pitch", "Pitch", nil, "Pitch axis value (-1.0 to 1.0)")
f.flyc_joystick_yaw = ProtoField.float ("dji_dumlv1.flyc_joystick_yaw", "Yaw", nil, "Yaw axis value (-1.0 to 1.0)")
f.flyc_joystick_throttle = ProtoField.float ("dji_dumlv1.flyc_joystick_throttle", "Throttle", nil, "Throttle value (-1.0 to 1.0)")

-- App Joystick (0x8E) - Similar to 0x29 but from mobile app
f.flyc_app_joystick_flag = ProtoField.uint8 ("dji_dumlv1.flyc_app_joystick_flag", "App Control Flag", base.HEX)
f.flyc_app_joystick_roll = ProtoField.float ("dji_dumlv1.flyc_app_joystick_roll", "App Roll", nil)
f.flyc_app_joystick_pitch = ProtoField.float ("dji_dumlv1.flyc_app_joystick_pitch", "App Pitch", nil)
f.flyc_app_joystick_yaw = ProtoField.float ("dji_dumlv1.flyc_app_joystick_yaw", "App Yaw", nil)
f.flyc_app_joystick_throttle = ProtoField.float ("dji_dumlv1.flyc_app_joystick_throttle", "App Throttle", nil)

-- Exec Fly (0x27)
f.flyc_exec_fly_type = ProtoField.uint8 ("dji_dumlv1.flyc_exec_fly_type", "Exec Fly Type", base.HEX, enums.FLYC_EXEC_FLY_TYPE_ENUM)

-- Home Point Set (0x31) - DataFlycSetHomePoint.java
f.flyc_home_point_type = ProtoField.uint8 ("dji_dumlv1.flyc_home_point_type", "Home Point Type", base.HEX, enums.FLYC_HOME_POINT_TYPE_ENUM)
f.flyc_home_point_latitude = ProtoField.double ("dji_dumlv1.flyc_home_point_latitude", "Latitude", nil, "Home latitude in radians")
f.flyc_home_point_longitude = ProtoField.double ("dji_dumlv1.flyc_home_point_longitude", "Longitude", nil, "Home longitude in radians")

-- Origin GPS Set/Get (0x03, 0x04)
f.flyc_origin_gps_latitude = ProtoField.double ("dji_dumlv1.flyc_origin_gps_latitude", "Origin Latitude", nil)
f.flyc_origin_gps_longitude = ProtoField.double ("dji_dumlv1.flyc_origin_gps_longitude", "Origin Longitude", nil)
f.flyc_origin_gps_altitude = ProtoField.float ("dji_dumlv1.flyc_origin_gps_altitude", "Origin Altitude", nil)

-- IOC Mode (0x2B, 0x2C) - Intelligent Orientation Control
f.flyc_ioc_mode_type = ProtoField.uint8 ("dji_dumlv1.flyc_ioc_mode_type", "IOC Mode Type", base.HEX, enums.FLYC_IOC_MODE_TYPE_ENUM)
f.flyc_ioc_mode_course_lock_angle = ProtoField.int16 ("dji_dumlv1.flyc_ioc_mode_course_lock_angle", "Course Lock Angle", base.DEC)

-- Navigation Switch (0x80)
f.flyc_nav_switch_cmd = ProtoField.uint8 ("dji_dumlv1.flyc_nav_switch_cmd", "Navigation Switch", base.HEX, enums.FLYC_NAV_SWITCH_CMD_ENUM)

-- Waypoint Mission Upload (0x82) - DataFlycUploadWayPointMissionMsg.java
f.flyc_wp_mission_id = ProtoField.uint8 ("dji_dumlv1.flyc_wp_mission_id", "Mission ID", base.DEC)
f.flyc_wp_mission_wp_count = ProtoField.uint8 ("dji_dumlv1.flyc_wp_mission_wp_count", "Waypoint Count", base.DEC)
f.flyc_wp_mission_max_vel = ProtoField.float ("dji_dumlv1.flyc_wp_mission_max_vel", "Max Velocity (m/s)", nil)
f.flyc_wp_mission_idle_vel = ProtoField.float ("dji_dumlv1.flyc_wp_mission_idle_vel", "Idle Velocity (m/s)", nil)
f.flyc_wp_mission_finish_action = ProtoField.uint8 ("dji_dumlv1.flyc_wp_mission_finish_action", "Finish Action", base.HEX, enums.FLYC_WP_FINISH_ACTION_ENUM)
f.flyc_wp_mission_exec_times = ProtoField.uint8 ("dji_dumlv1.flyc_wp_mission_exec_times", "Execute Times", base.DEC)
f.flyc_wp_mission_yaw_mode = ProtoField.uint8 ("dji_dumlv1.flyc_wp_mission_yaw_mode", "Yaw Mode", base.HEX, enums.FLYC_WP_YAW_MODE_ENUM)
f.flyc_wp_mission_trace_mode = ProtoField.uint8 ("dji_dumlv1.flyc_wp_mission_trace_mode", "Trace Mode", base.HEX, enums.FLYC_WP_TRACE_MODE_ENUM)
f.flyc_wp_mission_rc_loss_action = ProtoField.uint8 ("dji_dumlv1.flyc_wp_mission_rc_loss_action", "RC Loss Action", base.HEX, enums.FLYC_WP_RC_LOSS_ACTION_ENUM)
f.flyc_wp_mission_goto_first_mode = ProtoField.uint8 ("dji_dumlv1.flyc_wp_mission_goto_first_mode", "Goto First Mode", base.HEX, enums.FLYC_WP_GOTO_FIRST_MODE_ENUM)
f.flyc_wp_mission_latitude = ProtoField.double ("dji_dumlv1.flyc_wp_mission_latitude", "Reference Latitude", nil)
f.flyc_wp_mission_longitude = ProtoField.double ("dji_dumlv1.flyc_wp_mission_longitude", "Reference Longitude", nil)
f.flyc_wp_mission_altitude = ProtoField.float ("dji_dumlv1.flyc_wp_mission_altitude", "Reference Altitude", nil)

-- Waypoint Upload by Index (0x84) - DataFlycUploadWayPointMsgByIndex.java
f.flyc_wp_index = ProtoField.uint8 ("dji_dumlv1.flyc_wp_index", "Waypoint Index", base.DEC)
f.flyc_wp_latitude = ProtoField.double ("dji_dumlv1.flyc_wp_latitude", "Waypoint Latitude", nil)
f.flyc_wp_longitude = ProtoField.double ("dji_dumlv1.flyc_wp_longitude", "Waypoint Longitude", nil)
f.flyc_wp_altitude = ProtoField.float ("dji_dumlv1.flyc_wp_altitude", "Waypoint Altitude", nil)
f.flyc_wp_damping = ProtoField.float ("dji_dumlv1.flyc_wp_damping", "Waypoint Damping", nil)
f.flyc_wp_target_yaw = ProtoField.int16 ("dji_dumlv1.flyc_wp_target_yaw", "Target Yaw", base.DEC)
f.flyc_wp_target_gimbal_pitch = ProtoField.int16 ("dji_dumlv1.flyc_wp_target_gimbal_pitch", "Gimbal Pitch", base.DEC)
f.flyc_wp_turn_mode = ProtoField.uint8 ("dji_dumlv1.flyc_wp_turn_mode", "Turn Mode", base.HEX)
f.flyc_wp_has_action = ProtoField.uint8 ("dji_dumlv1.flyc_wp_has_action", "Has Action", base.HEX)
f.flyc_wp_action_time_limit = ProtoField.uint16 ("dji_dumlv1.flyc_wp_action_time_limit", "Action Time Limit (ms)", base.DEC)
f.flyc_wp_action_num = ProtoField.uint8 ("dji_dumlv1.flyc_wp_action_num", "Action Count", base.DEC)
f.flyc_wp_action_repeat = ProtoField.uint8 ("dji_dumlv1.flyc_wp_action_repeat", "Action Repeat", base.DEC)

-- Mission Start/Stop (0x86)
f.flyc_wp_mission_switch = ProtoField.uint8 ("dji_dumlv1.flyc_wp_mission_switch", "Mission Switch", base.HEX, {[0]='Stop', [1]='Start'})

-- Mission Pause/Resume (0x87)
f.flyc_wp_mission_pause = ProtoField.uint8 ("dji_dumlv1.flyc_wp_mission_pause", "Pause/Resume", base.HEX, {[0]='Resume', [1]='Pause'})

-- HotPoint Mission (0x8A) - DataFlycHotPointMission.java
f.flyc_hp_latitude = ProtoField.double ("dji_dumlv1.flyc_hp_latitude", "HotPoint Latitude", nil)
f.flyc_hp_longitude = ProtoField.double ("dji_dumlv1.flyc_hp_longitude", "HotPoint Longitude", nil)
f.flyc_hp_altitude = ProtoField.float ("dji_dumlv1.flyc_hp_altitude", "HotPoint Altitude", nil)
f.flyc_hp_radius = ProtoField.float ("dji_dumlv1.flyc_hp_radius", "Orbit Radius (m)", nil)
f.flyc_hp_angular_vel = ProtoField.float ("dji_dumlv1.flyc_hp_angular_vel", "Angular Velocity (deg/s)", nil)
f.flyc_hp_direction = ProtoField.uint8 ("dji_dumlv1.flyc_hp_direction", "Direction", base.HEX, {[0]='Clockwise', [1]='Counter-Clockwise'})
f.flyc_hp_start_point = ProtoField.uint8 ("dji_dumlv1.flyc_hp_start_point", "Start Point", base.HEX)
f.flyc_hp_yaw_mode = ProtoField.uint8 ("dji_dumlv1.flyc_hp_yaw_mode", "Yaw Mode", base.HEX)

-- Follow Me Mission (0x90) - DataFlycFollowMeMission.java
f.flyc_follow_latitude = ProtoField.double ("dji_dumlv1.flyc_follow_latitude", "Target Latitude", nil)
f.flyc_follow_longitude = ProtoField.double ("dji_dumlv1.flyc_follow_longitude", "Target Longitude", nil)
f.flyc_follow_altitude = ProtoField.uint16 ("dji_dumlv1.flyc_follow_altitude", "Target Altitude", base.DEC)
f.flyc_follow_heading = ProtoField.uint16 ("dji_dumlv1.flyc_follow_heading", "Target Heading", base.DEC)

-- RTK Switch (0x69)
f.flyc_rtk_switch_enable = ProtoField.uint8 ("dji_dumlv1.flyc_rtk_switch_enable", "RTK Enable", base.HEX, {[0]='GPS Mode', [1]='RTK Mode'})

-- Attitude Control (0xAB)
f.flyc_attitude_roll = ProtoField.float ("dji_dumlv1.flyc_attitude_roll", "Roll Angle", nil)
f.flyc_attitude_pitch = ProtoField.float ("dji_dumlv1.flyc_attitude_pitch", "Pitch Angle", nil)
f.flyc_attitude_yaw = ProtoField.float ("dji_dumlv1.flyc_attitude_yaw", "Yaw Angle", nil)
f.flyc_attitude_throttle = ProtoField.float ("dji_dumlv1.flyc_attitude_throttle", "Throttle", nil)

-- Limit Params (0x2D, 0x2E)
f.flyc_limit_max_height = ProtoField.float ("dji_dumlv1.flyc_limit_max_height", "Max Height (m)", nil)
f.flyc_limit_max_radius = ProtoField.float ("dji_dumlv1.flyc_limit_max_radius", "Max Radius (m)", nil)
f.flyc_limit_enable_height = ProtoField.uint8 ("dji_dumlv1.flyc_limit_enable_height", "Height Limit Enable", base.HEX)
f.flyc_limit_enable_radius = ProtoField.uint8 ("dji_dumlv1.flyc_limit_enable_radius", "Radius Limit Enable", base.HEX)

-- Battery Voltage Alarm (0x2F, 0x30)
f.flyc_batt_alarm_level1 = ProtoField.uint8 ("dji_dumlv1.flyc_batt_alarm_level1", "Level 1 Threshold (%)", base.DEC)
f.flyc_batt_alarm_level2 = ProtoField.uint8 ("dji_dumlv1.flyc_batt_alarm_level2", "Level 2 Threshold (%)", base.DEC)
f.flyc_batt_alarm_action = ProtoField.uint8 ("dji_dumlv1.flyc_batt_alarm_action", "Low Battery Action", base.HEX, {[0]='Warning', [1]='Go Home', [2]='Land'})

--------------------------------------------------------------------------------
-- Dissector functions for extended commands
--------------------------------------------------------------------------------

-- Joystick Dissector (0x29)
local function flyc_joystick_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 17 then
        subtree:add_le (f.flyc_joystick_flag, payload(offset, 1))
        offset = offset + 1

        subtree:add_le (f.flyc_joystick_roll, payload(offset, 4))
        offset = offset + 4

        subtree:add_le (f.flyc_joystick_pitch, payload(offset, 4))
        offset = offset + 4

        subtree:add_le (f.flyc_joystick_yaw, payload(offset, 4))
        offset = offset + 4

        subtree:add_le (f.flyc_joystick_throttle, payload(offset, 4))
        offset = offset + 4
    end

    if (payload:len() ~= offset) then subtree:add_expert_info(PI_PROTOCOL,PI_WARN,"Joystick: Payload size different than expected") end
end

-- App Joystick Dissector (0x8E)
local function flyc_app_joystick_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 17 then
        subtree:add_le (f.flyc_app_joystick_flag, payload(offset, 1))
        offset = offset + 1

        subtree:add_le (f.flyc_app_joystick_roll, payload(offset, 4))
        offset = offset + 4

        subtree:add_le (f.flyc_app_joystick_pitch, payload(offset, 4))
        offset = offset + 4

        subtree:add_le (f.flyc_app_joystick_yaw, payload(offset, 4))
        offset = offset + 4

        subtree:add_le (f.flyc_app_joystick_throttle, payload(offset, 4))
        offset = offset + 4
    end
end

-- Exec Fly Dissector (0x27)
local function flyc_exec_fly_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 1 then
        subtree:add_le (f.flyc_exec_fly_type, payload(offset, 1))
        offset = offset + 1
    end
end

-- Home Point Set Dissector (0x31)
local function flyc_home_point_set_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 1 then
        subtree:add_le (f.flyc_home_point_type, payload(offset, 1))
        offset = offset + 1
    end

    if payload:len() >= 17 then
        subtree:add_le (f.flyc_home_point_latitude, payload(offset, 8))
        offset = offset + 8

        subtree:add_le (f.flyc_home_point_longitude, payload(offset, 8))
        offset = offset + 8
    end
end

-- Origin GPS Set Dissector (0x03)
local function flyc_origin_gps_set_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 20 then
        subtree:add_le (f.flyc_origin_gps_latitude, payload(offset, 8))
        offset = offset + 8

        subtree:add_le (f.flyc_origin_gps_longitude, payload(offset, 8))
        offset = offset + 8

        subtree:add_le (f.flyc_origin_gps_altitude, payload(offset, 4))
        offset = offset + 4
    end
end

-- IOC Mode Set Dissector (0x2B)
local function flyc_ioc_mode_set_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 1 then
        subtree:add_le (f.flyc_ioc_mode_type, payload(offset, 1))
        offset = offset + 1
    end

    if payload:len() >= 3 then
        subtree:add_le (f.flyc_ioc_mode_course_lock_angle, payload(offset, 2))
        offset = offset + 2
    end
end

-- Navigation Switch Dissector (0x80)
local function flyc_nav_switch_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 1 then
        subtree:add_le (f.flyc_nav_switch_cmd, payload(offset, 1))
        offset = offset + 1
    end
end

-- Waypoint Mission Upload Dissector (0x82)
local function flyc_wp_mission_upload_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 2 then
        subtree:add_le (f.flyc_wp_mission_id, payload(offset, 1))
        offset = offset + 1

        subtree:add_le (f.flyc_wp_mission_wp_count, payload(offset, 1))
        offset = offset + 1
    end

    if payload:len() >= 10 then
        subtree:add_le (f.flyc_wp_mission_max_vel, payload(offset, 4))
        offset = offset + 4

        subtree:add_le (f.flyc_wp_mission_idle_vel, payload(offset, 4))
        offset = offset + 4
    end

    if payload:len() >= 16 then
        subtree:add_le (f.flyc_wp_mission_finish_action, payload(offset, 1))
        offset = offset + 1

        subtree:add_le (f.flyc_wp_mission_exec_times, payload(offset, 1))
        offset = offset + 1

        subtree:add_le (f.flyc_wp_mission_yaw_mode, payload(offset, 1))
        offset = offset + 1

        subtree:add_le (f.flyc_wp_mission_trace_mode, payload(offset, 1))
        offset = offset + 1

        subtree:add_le (f.flyc_wp_mission_rc_loss_action, payload(offset, 1))
        offset = offset + 1

        subtree:add_le (f.flyc_wp_mission_goto_first_mode, payload(offset, 1))
        offset = offset + 1
    end

    if payload:len() >= 36 then
        subtree:add_le (f.flyc_wp_mission_latitude, payload(offset, 8))
        offset = offset + 8

        subtree:add_le (f.flyc_wp_mission_longitude, payload(offset, 8))
        offset = offset + 8

        subtree:add_le (f.flyc_wp_mission_altitude, payload(offset, 4))
        offset = offset + 4
    end
end

-- Waypoint Upload by Index Dissector (0x84)
local function flyc_wp_upload_by_index_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 1 then
        subtree:add_le (f.flyc_wp_index, payload(offset, 1))
        offset = offset + 1
    end

    if payload:len() >= 25 then
        subtree:add_le (f.flyc_wp_latitude, payload(offset, 8))
        offset = offset + 8

        subtree:add_le (f.flyc_wp_longitude, payload(offset, 8))
        offset = offset + 8

        subtree:add_le (f.flyc_wp_altitude, payload(offset, 4))
        offset = offset + 4

        subtree:add_le (f.flyc_wp_damping, payload(offset, 4))
        offset = offset + 4
    end

    if payload:len() >= 31 then
        subtree:add_le (f.flyc_wp_target_yaw, payload(offset, 2))
        offset = offset + 2

        subtree:add_le (f.flyc_wp_target_gimbal_pitch, payload(offset, 2))
        offset = offset + 2

        subtree:add_le (f.flyc_wp_turn_mode, payload(offset, 1))
        offset = offset + 1

        subtree:add_le (f.flyc_wp_has_action, payload(offset, 1))
        offset = offset + 1
    end

    if payload:len() >= 35 then
        subtree:add_le (f.flyc_wp_action_time_limit, payload(offset, 2))
        offset = offset + 2

        subtree:add_le (f.flyc_wp_action_num, payload(offset, 1))
        offset = offset + 1

        subtree:add_le (f.flyc_wp_action_repeat, payload(offset, 1))
        offset = offset + 1
    end
end

-- Mission Start/Stop Dissector (0x86)
local function flyc_wp_mission_switch_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 1 then
        subtree:add_le (f.flyc_wp_mission_switch, payload(offset, 1))
        offset = offset + 1
    end
end

-- Mission Pause/Resume Dissector (0x87)
local function flyc_wp_mission_pause_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 1 then
        subtree:add_le (f.flyc_wp_mission_pause, payload(offset, 1))
        offset = offset + 1
    end
end

-- HotPoint Mission Start Dissector (0x8A)
local function flyc_hp_mission_start_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 28 then
        subtree:add_le (f.flyc_hp_latitude, payload(offset, 8))
        offset = offset + 8

        subtree:add_le (f.flyc_hp_longitude, payload(offset, 8))
        offset = offset + 8

        subtree:add_le (f.flyc_hp_altitude, payload(offset, 4))
        offset = offset + 4

        subtree:add_le (f.flyc_hp_radius, payload(offset, 4))
        offset = offset + 4

        subtree:add_le (f.flyc_hp_angular_vel, payload(offset, 4))
        offset = offset + 4
    end

    if payload:len() >= 31 then
        subtree:add_le (f.flyc_hp_direction, payload(offset, 1))
        offset = offset + 1

        subtree:add_le (f.flyc_hp_start_point, payload(offset, 1))
        offset = offset + 1

        subtree:add_le (f.flyc_hp_yaw_mode, payload(offset, 1))
        offset = offset + 1
    end
end

-- Follow Me Mission Start Dissector (0x90)
local function flyc_follow_mission_start_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 20 then
        subtree:add_le (f.flyc_follow_latitude, payload(offset, 8))
        offset = offset + 8

        subtree:add_le (f.flyc_follow_longitude, payload(offset, 8))
        offset = offset + 8

        subtree:add_le (f.flyc_follow_altitude, payload(offset, 2))
        offset = offset + 2

        subtree:add_le (f.flyc_follow_heading, payload(offset, 2))
        offset = offset + 2
    end
end

-- RTK Switch Dissector (0x69)
local function flyc_rtk_switch_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 1 then
        subtree:add_le (f.flyc_rtk_switch_enable, payload(offset, 1))
        offset = offset + 1
    end
end

-- Attitude Control Dissector (0xAB)
local function flyc_attitude_ctrl_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 16 then
        subtree:add_le (f.flyc_attitude_roll, payload(offset, 4))
        offset = offset + 4

        subtree:add_le (f.flyc_attitude_pitch, payload(offset, 4))
        offset = offset + 4

        subtree:add_le (f.flyc_attitude_yaw, payload(offset, 4))
        offset = offset + 4

        subtree:add_le (f.flyc_attitude_throttle, payload(offset, 4))
        offset = offset + 4
    end
end

-- Limit Params Set Dissector (0x2D)
local function flyc_limit_params_set_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 10 then
        subtree:add_le (f.flyc_limit_max_height, payload(offset, 4))
        offset = offset + 4

        subtree:add_le (f.flyc_limit_max_radius, payload(offset, 4))
        offset = offset + 4

        subtree:add_le (f.flyc_limit_enable_height, payload(offset, 1))
        offset = offset + 1

        subtree:add_le (f.flyc_limit_enable_radius, payload(offset, 1))
        offset = offset + 1
    end
end

-- Remote ID / Privacy Control (0xDA) — CIA Jeep Doors
-- Reference: https://github.com/MAVProxyUser/CIAJeepDoors
-- Src: DEVICE_PC (0x0A) id=1   Dst: DEVICE_FLIGHT_CONTROLLER (0x03) id=6
-- GET_PRIVACY quirk: dst id=0 (not id=6)
-- SET_PRIVACY payload: [0x05][val][0x00][0x00][0x00]  (4-byte LE uint32)
-- M300 workaround:     write 0x40 first, then target value

enums.FLYC_REMOTE_ID_SUB_CMD_ENUM = {
    [0x01] = 'SET_FLIGHT_PURPOSE',
    [0x02] = 'GET_FLIGHT_PURPOSE',
    [0x03] = 'SET_DRONE_ID',
    [0x04] = 'GET_DRONE_ID',
    [0x05] = 'SET_PRIVACY',
    [0x06] = 'GET_PRIVACY',
}

f.flyc_remote_id_sub_cmd        = ProtoField.uint8  ("dji_dumlv1.flyc_remote_id_sub_cmd",         "Remote ID Sub-Command",  base.HEX, enums.FLYC_REMOTE_ID_SUB_CMD_ENUM)
f.flyc_remote_id_privacy_raw    = ProtoField.uint32 ("dji_dumlv1.flyc_remote_id_privacy_raw",      "Privacy Flags (LE u32)", base.HEX)
f.flyc_remote_id_priv_serial    = ProtoField.bool   ("dji_dumlv1.flyc_remote_id_priv_serial",      "Serial Number",          8, {"Broadcasting", "Hidden"}, 0x01)
f.flyc_remote_id_priv_state     = ProtoField.bool   ("dji_dumlv1.flyc_remote_id_priv_state",       "State (pos/roll/IMU)",   8, {"Broadcasting", "Hidden"}, 0x02)
f.flyc_remote_id_priv_rth       = ProtoField.bool   ("dji_dumlv1.flyc_remote_id_priv_rth",         "Return-to-Home pos",     8, {"Broadcasting", "Hidden"}, 0x04)
f.flyc_remote_id_priv_droneid   = ProtoField.bool   ("dji_dumlv1.flyc_remote_id_priv_droneid",     "Drone ID string",        8, {"Broadcasting", "Hidden"}, 0x08)
f.flyc_remote_id_priv_purpose   = ProtoField.bool   ("dji_dumlv1.flyc_remote_id_priv_purpose",     "Flight Purpose string",  8, {"Broadcasting", "Hidden"}, 0x10)
f.flyc_remote_id_priv_uuid      = ProtoField.bool   ("dji_dumlv1.flyc_remote_id_priv_uuid",        "UUID",                   8, {"Broadcasting", "Hidden"}, 0x20)
f.flyc_remote_id_priv_pilot     = ProtoField.bool   ("dji_dumlv1.flyc_remote_id_priv_pilot",       "Pilot Position",         8, {"Broadcasting", "Hidden"}, 0x40)
f.flyc_remote_id_priv_bit7      = ProtoField.bool   ("dji_dumlv1.flyc_remote_id_priv_bit7",        "Unknown (bit 7)",        8, {"Broadcasting", "Hidden"}, 0x80)
f.flyc_remote_id_drone_id       = ProtoField.string ("dji_dumlv1.flyc_remote_id_drone_id",         "Drone ID")
f.flyc_remote_id_flight_purpose = ProtoField.string ("dji_dumlv1.flyc_remote_id_flight_purpose",   "Flight Purpose")

local function flyc_remote_id_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() < 1 then return end

    local sub = payload(offset, 1):uint()
    subtree:add_le(f.flyc_remote_id_sub_cmd, payload(offset, 1))
    offset = offset + 1

    if (sub == 0x05 or sub == 0x06) then
        -- SET_PRIVACY / GET_PRIVACY response: [sub][val][0x00][0x00][0x00]
        if payload:len() >= offset + 4 then
            local priv_tree = subtree:add_le(f.flyc_remote_id_privacy_raw, payload(offset, 4))
            -- named bits are in the low byte (byte 0 of the LE uint32)
            priv_tree:add(f.flyc_remote_id_priv_serial,  payload(offset, 1))
            priv_tree:add(f.flyc_remote_id_priv_state,   payload(offset, 1))
            priv_tree:add(f.flyc_remote_id_priv_rth,     payload(offset, 1))
            priv_tree:add(f.flyc_remote_id_priv_droneid, payload(offset, 1))
            priv_tree:add(f.flyc_remote_id_priv_purpose, payload(offset, 1))
            priv_tree:add(f.flyc_remote_id_priv_uuid,    payload(offset, 1))
            priv_tree:add(f.flyc_remote_id_priv_pilot,   payload(offset, 1))
            priv_tree:add(f.flyc_remote_id_priv_bit7,    payload(offset, 1))
            offset = offset + 4
        elseif payload:len() >= offset + 1 then
            -- short form (1-byte value, seen on some FW versions)
            local priv_tree = subtree:add_le(f.flyc_remote_id_privacy_raw, payload(offset, 1))
            priv_tree:add(f.flyc_remote_id_priv_serial,  payload(offset, 1))
            priv_tree:add(f.flyc_remote_id_priv_state,   payload(offset, 1))
            priv_tree:add(f.flyc_remote_id_priv_rth,     payload(offset, 1))
            priv_tree:add(f.flyc_remote_id_priv_droneid, payload(offset, 1))
            priv_tree:add(f.flyc_remote_id_priv_purpose, payload(offset, 1))
            priv_tree:add(f.flyc_remote_id_priv_uuid,    payload(offset, 1))
            priv_tree:add(f.flyc_remote_id_priv_pilot,   payload(offset, 1))
            priv_tree:add(f.flyc_remote_id_priv_bit7,    payload(offset, 1))
            offset = offset + 1
        end
    elseif (sub == 0x03 or sub == 0x04) then
        -- SET_DRONE_ID / GET_DRONE_ID: remainder is ASCII (may be null-padded)
        local rem = payload:len() - offset
        if rem > 0 then
            subtree:add(f.flyc_remote_id_drone_id, payload(offset, rem))
            offset = offset + rem
        end
    elseif (sub == 0x01 or sub == 0x02) then
        -- SET_FLIGHT_PURPOSE / GET_FLIGHT_PURPOSE
        local rem = payload:len() - offset
        if rem > 0 then
            subtree:add(f.flyc_remote_id_flight_purpose, payload(offset, rem))
            offset = offset + rem
        end
    end

    if (payload:len() ~= offset) then
        subtree:add_expert_info(PI_PROTOCOL, PI_NOTE, "Remote ID: trailing bytes after decoded fields")
    end
end

-- Battery Voltage Alarm Set Dissector (0x2F)
local function flyc_batt_alarm_set_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 3 then
        subtree:add_le (f.flyc_batt_alarm_level1, payload(offset, 1))
        offset = offset + 1

        subtree:add_le (f.flyc_batt_alarm_level2, payload(offset, 1))
        offset = offset + 1

        subtree:add_le (f.flyc_batt_alarm_action, payload(offset, 1))
        offset = offset + 1
    end
end

--------------------------------------------------------------------------------
-- Register extended dissectors to the main FLYC_UART_CMD_DISSECT table
--------------------------------------------------------------------------------

-- Add new dissectors to the existing table (don't overwrite existing ones)
if FLYC_UART_CMD_DISSECT then
    -- Joystick commands
    FLYC_UART_CMD_DISSECT[0x29] = flyc_joystick_dissector
    FLYC_UART_CMD_DISSECT[0x8E] = flyc_app_joystick_dissector

    -- Basic flight commands
    FLYC_UART_CMD_DISSECT[0x27] = flyc_exec_fly_dissector
    FLYC_UART_CMD_DISSECT[0x03] = flyc_origin_gps_set_dissector
    FLYC_UART_CMD_DISSECT[0x31] = flyc_home_point_set_dissector
    FLYC_UART_CMD_DISSECT[0x2B] = flyc_ioc_mode_set_dissector

    -- Mission commands
    FLYC_UART_CMD_DISSECT[0x80] = flyc_nav_switch_dissector
    FLYC_UART_CMD_DISSECT[0x82] = flyc_wp_mission_upload_dissector
    FLYC_UART_CMD_DISSECT[0x84] = flyc_wp_upload_by_index_dissector
    FLYC_UART_CMD_DISSECT[0x86] = flyc_wp_mission_switch_dissector
    FLYC_UART_CMD_DISSECT[0x87] = flyc_wp_mission_pause_dissector
    FLYC_UART_CMD_DISSECT[0x8A] = flyc_hp_mission_start_dissector
    FLYC_UART_CMD_DISSECT[0x90] = flyc_follow_mission_start_dissector

    -- Configuration commands
    FLYC_UART_CMD_DISSECT[0x69] = flyc_rtk_switch_dissector
    FLYC_UART_CMD_DISSECT[0xAB] = flyc_attitude_ctrl_dissector
    FLYC_UART_CMD_DISSECT[0x2D] = flyc_limit_params_set_dissector
    FLYC_UART_CMD_DISSECT[0x2F] = flyc_batt_alarm_set_dissector

    -- Remote ID / Privacy Control (CIA Jeep Doors)
    FLYC_UART_CMD_DISSECT[0xda] = flyc_remote_id_dissector

    print("DJI DUMLv1 FlyC Extension: Added 17 new dissectors")
else
    print("Warning: FLYC_UART_CMD_DISSECT not found - FlyC extension not loaded")
end

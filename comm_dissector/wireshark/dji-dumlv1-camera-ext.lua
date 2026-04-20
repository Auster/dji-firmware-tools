-- Extended definitions for DJI DUMLv1 protocol dissector
-- Additional dissectors for command set 0x02 - Camera
-- Based on reverse engineering from DJIPILOT_src
--
-- This file extends dji-dumlv1-camera.lua with additional dissectors
-- Load after the main camera dissector

local f = DJI_DUMLv1_PROTO.fields
local enums = {}

--------------------------------------------------------------------------------
-- Extended enums based on DJIPILOT_src research
--------------------------------------------------------------------------------

-- Camera Work Mode (DataCameraSetMode.java)
enums.CAMERA_WORK_MODE_ENUM = {
    [0x00] = 'Photo Capture',
    [0x01] = 'Video Record',
    [0x02] = 'Playback',
    [0x03] = 'Media Download',
    [0x04] = 'Broadcast',
    [0x05] = 'Unknown5',
    [0xFF] = 'Unknown',
}

-- Photo Mode (DataCameraSetPhoto.java)
enums.CAMERA_PHOTO_MODE_ENUM = {
    [0x00] = 'Stop',
    [0x01] = 'Single',
    [0x02] = 'HDR',
    [0x03] = 'Full View',
    [0x04] = 'Burst',
    [0x05] = 'AEB',
    [0x06] = 'Timed/Interval',
    [0x07] = 'App Full View',
    [0x08] = 'Tracking',
    [0x09] = 'Raw Burst',
    [0x0A] = 'HDR+',
    [0x0B] = 'Hyper Night',
    [0x0C] = 'Hyper Lapse',
    [0x0D] = 'Panorama True',
    [0x0E] = 'Super Resolution',
    [0x0F] = 'High Resolution',
    [0x11] = 'Smart Capture',
    [0x62] = 'Bokeh/Portrait',
    [0x63] = 'Panorama',
    [0xFF] = 'Other/Unknown',
}

-- Record Mode (DataCameraSetRecord.java)
enums.CAMERA_RECORD_MODE_ENUM = {
    [0x00] = 'Stop',
    [0x01] = 'Start',
    [0x02] = 'Pause',
    [0x03] = 'Resume',
    [0x07] = 'Other',
}

-- Exposure Mode
enums.CAMERA_EXPOSURE_MODE_ENUM = {
    [0x00] = 'Program Auto',
    [0x01] = 'Shutter Priority',
    [0x02] = 'Aperture Priority',
    [0x03] = 'Manual',
    [0x04] = 'Unknown',
}

-- Focus Mode
enums.CAMERA_FOCUS_MODE_ENUM = {
    [0x00] = 'Manual Focus',
    [0x01] = 'Auto Focus',
    [0x02] = 'Continuous AF',
    [0x03] = 'Unknown',
}

-- White Balance Mode
enums.CAMERA_WHITE_BALANCE_ENUM = {
    [0x00] = 'Auto',
    [0x01] = 'Sunny',
    [0x02] = 'Cloudy',
    [0x03] = 'Incandescent',
    [0x04] = 'Fluorescent',
    [0x05] = 'Custom',
    [0x06] = 'Preset 1',
    [0x07] = 'Preset 2',
    [0x08] = 'Preset 3',
    [0xFF] = 'Unknown',
}

-- Metering Mode
enums.CAMERA_METERING_MODE_ENUM = {
    [0x00] = 'Center',
    [0x01] = 'Average',
    [0x02] = 'Spot',
    [0x03] = 'Unknown',
}

-- Photo Format
enums.CAMERA_PHOTO_FORMAT_ENUM = {
    [0x00] = 'RAW',
    [0x01] = 'JPEG',
    [0x02] = 'RAW+JPEG',
    [0x03] = 'TIFF',
    [0x04] = 'RAW+TIFF',
    [0xFF] = 'Unknown',
}

-- Video Format
enums.CAMERA_VIDEO_FORMAT_ENUM = {
    [0x00] = 'MOV',
    [0x01] = 'MP4',
    [0x02] = 'TIFF Seq',
    [0xFF] = 'Unknown',
}

-- Anti-Flicker
enums.CAMERA_ANTI_FLICKER_ENUM = {
    [0x00] = 'Auto',
    [0x01] = '60Hz',
    [0x02] = '50Hz',
    [0x03] = 'Disabled',
}

-- Zoom Control Mode
enums.CAMERA_ZOOM_MODE_ENUM = {
    [0x00] = 'Stop',
    [0x01] = 'Zoom In',
    [0x02] = 'Zoom Out',
    [0x03] = 'Position',
}

-- Focus Control Mode
enums.CAMERA_FOCUS_CTRL_MODE_ENUM = {
    [0x00] = 'Stop',
    [0x01] = 'Auto Focus',
    [0x02] = 'Continuous',
    [0x03] = 'Step Near',
    [0x04] = 'Step Far',
    [0x05] = 'Position',
}

--------------------------------------------------------------------------------
-- Field definitions for extended camera commands
--------------------------------------------------------------------------------

-- Camera Work Mode (0x10, 0x11)
f.camera_work_mode = ProtoField.uint8 ("dji_dumlv1.camera_work_mode", "Work Mode", base.HEX, enums.CAMERA_WORK_MODE_ENUM)

-- Photo Capture (0x01) - DataCameraSetPhoto.java
f.camera_photo_mode = ProtoField.uint8 ("dji_dumlv1.camera_photo_mode", "Photo Mode", base.HEX, enums.CAMERA_PHOTO_MODE_ENUM)

-- Video Record (0x02) - DataCameraSetRecord.java
f.camera_record_mode = ProtoField.uint8 ("dji_dumlv1.camera_record_mode", "Record Mode", base.HEX, enums.CAMERA_RECORD_MODE_ENUM)

-- Photo Format (0x12, 0x13)
f.camera_photo_format = ProtoField.uint8 ("dji_dumlv1.camera_photo_format", "Photo Format", base.HEX, enums.CAMERA_PHOTO_FORMAT_ENUM)

-- Video Format (0x18, 0x19)
f.camera_video_format = ProtoField.uint8 ("dji_dumlv1.camera_video_format", "Video Format", base.HEX, enums.CAMERA_VIDEO_FORMAT_ENUM)

-- Exposure Mode (0x1E, 0x1F)
f.camera_exposure_mode = ProtoField.uint8 ("dji_dumlv1.camera_exposure_mode", "Exposure Mode", base.HEX, enums.CAMERA_EXPOSURE_MODE_ENUM)

-- Metering Mode (0x22, 0x23)
f.camera_metering_mode = ProtoField.uint8 ("dji_dumlv1.camera_metering_mode", "Metering Mode", base.HEX, enums.CAMERA_METERING_MODE_ENUM)

-- Focus Mode (0x24, 0x25)
f.camera_focus_mode = ProtoField.uint8 ("dji_dumlv1.camera_focus_mode", "Focus Mode", base.HEX, enums.CAMERA_FOCUS_MODE_ENUM)

-- Aperture (0x26, 0x27)
f.camera_aperture = ProtoField.uint16 ("dji_dumlv1.camera_aperture", "Aperture (x100)", base.DEC)

-- Shutter Speed (0x28, 0x29)
f.camera_shutter_time_s = ProtoField.uint8 ("dji_dumlv1.camera_shutter_time_s", "Shutter Seconds", base.DEC)
f.camera_shutter_time_sub = ProtoField.uint16 ("dji_dumlv1.camera_shutter_time_sub", "Shutter Subdivision", base.DEC)
f.camera_shutter_reciprocal = ProtoField.uint8 ("dji_dumlv1.camera_shutter_reciprocal", "Reciprocal", base.HEX, {[0]='Direct', [1]='1/x'})

-- ISO (0x2A, 0x2B)
f.camera_iso_value = ProtoField.uint32 ("dji_dumlv1.camera_iso_value", "ISO Value", base.DEC)
f.camera_iso_type = ProtoField.uint8 ("dji_dumlv1.camera_iso_type", "ISO Type", base.HEX, {[0]='Fixed', [1]='Auto'})

-- White Balance (0x2C, 0x2D)
f.camera_white_balance = ProtoField.uint8 ("dji_dumlv1.camera_white_balance", "White Balance", base.HEX, enums.CAMERA_WHITE_BALANCE_ENUM)
f.camera_white_balance_kelvin = ProtoField.uint16 ("dji_dumlv1.camera_white_balance_kelvin", "Color Temp (K)", base.DEC)

-- Exposure Compensation/Bias (0x2E, 0x2F)
f.camera_exposure_bias = ProtoField.int8 ("dji_dumlv1.camera_exposure_bias", "EV Compensation (1/3 stops)", base.DEC)

-- Focus Region (0x30, 0x31)
f.camera_focus_region_x = ProtoField.float ("dji_dumlv1.camera_focus_region_x", "Focus X (0-1)", nil)
f.camera_focus_region_y = ProtoField.float ("dji_dumlv1.camera_focus_region_y", "Focus Y (0-1)", nil)

-- Metering Region (0x32, 0x33)
f.camera_metering_region_x = ProtoField.float ("dji_dumlv1.camera_metering_region_x", "Meter X (0-1)", nil)
f.camera_metering_region_y = ProtoField.float ("dji_dumlv1.camera_metering_region_y", "Meter Y (0-1)", nil)

-- Sharpness (0x38, 0x39)
f.camera_sharpness = ProtoField.int8 ("dji_dumlv1.camera_sharpness", "Sharpness", base.DEC)

-- Contrast (0x3A, 0x3B)
f.camera_contrast = ProtoField.int8 ("dji_dumlv1.camera_contrast", "Contrast", base.DEC)

-- Saturation (0x3C, 0x3D)
f.camera_saturation = ProtoField.int8 ("dji_dumlv1.camera_saturation", "Saturation", base.DEC)

-- Hue (0x3E, 0x3F)
f.camera_hue = ProtoField.int8 ("dji_dumlv1.camera_hue", "Hue", base.DEC)

-- Anti-Flicker (0x46, 0x47)
f.camera_anti_flicker = ProtoField.uint8 ("dji_dumlv1.camera_anti_flicker", "Anti-Flicker", base.HEX, enums.CAMERA_ANTI_FLICKER_ENUM)

-- Zoom Parameters (0x53) - DataCameraSetZoomParams.java
f.camera_zoom_mode = ProtoField.uint8 ("dji_dumlv1.camera_zoom_mode", "Zoom Mode", base.HEX, enums.CAMERA_ZOOM_MODE_ENUM)
f.camera_zoom_speed = ProtoField.uint8 ("dji_dumlv1.camera_zoom_speed", "Zoom Speed", base.DEC)
f.camera_zoom_focal_length = ProtoField.uint16 ("dji_dumlv1.camera_zoom_focal_length", "Focal Length (mm)", base.DEC)

-- Focus Parameters (0x52) - DataCameraSetFocusParam.java
f.camera_focus_ctrl_mode = ProtoField.uint8 ("dji_dumlv1.camera_focus_ctrl_mode", "Focus Control Mode", base.HEX, enums.CAMERA_FOCUS_CTRL_MODE_ENUM)
f.camera_focus_distance = ProtoField.uint16 ("dji_dumlv1.camera_focus_distance", "Focus Distance (cm)", base.DEC)
f.camera_focus_x = ProtoField.float ("dji_dumlv1.camera_focus_x", "Focus Point X (0-1)", nil)
f.camera_focus_y = ProtoField.float ("dji_dumlv1.camera_focus_y", "Focus Point Y (0-1)", nil)

-- Burst Mode (0x48, 0x49)
f.camera_burst_count = ProtoField.uint8 ("dji_dumlv1.camera_burst_count", "Burst Count", base.DEC)

-- Interval/Timer Mode (0x4A, 0x4B)
f.camera_interval_count = ProtoField.uint8 ("dji_dumlv1.camera_interval_count", "Interval Count", base.DEC)
f.camera_interval_seconds = ProtoField.uint16 ("dji_dumlv1.camera_interval_seconds", "Interval (seconds)", base.DEC)

-- AEB Parameters (0x4C, 0x4D)
f.camera_aeb_count = ProtoField.uint8 ("dji_dumlv1.camera_aeb_count", "AEB Count", base.DEC)
f.camera_aeb_step = ProtoField.uint8 ("dji_dumlv1.camera_aeb_step", "AEB Step (EV)", base.DEC)

-- SD Card Info (0x71)
f.camera_sd_inserted = ProtoField.uint8 ("dji_dumlv1.camera_sd_inserted", "SD Inserted", base.HEX, {[0]='No', [1]='Yes'})
f.camera_sd_total_mb = ProtoField.uint32 ("dji_dumlv1.camera_sd_total_mb", "SD Total (MB)", base.DEC)
f.camera_sd_free_mb = ProtoField.uint32 ("dji_dumlv1.camera_sd_free_mb", "SD Free (MB)", base.DEC)
f.camera_sd_photo_count = ProtoField.uint32 ("dji_dumlv1.camera_sd_photo_count", "Photo Count", base.DEC)
f.camera_sd_video_seconds = ProtoField.uint32 ("dji_dumlv1.camera_sd_video_seconds", "Video Remaining (s)", base.DEC)

-- Format SD Card (0x72)
f.camera_format_slow = ProtoField.uint8 ("dji_dumlv1.camera_format_slow", "Slow Format", base.HEX, {[0]='Quick', [1]='Full'})

-- Video Playback Control (0x7A)
f.camera_playback_cmd = ProtoField.uint8 ("dji_dumlv1.camera_playback_cmd", "Playback Command", base.HEX, {
    [0x00] = 'Stop',
    [0x01] = 'Play',
    [0x02] = 'Pause',
    [0x03] = 'Seek',
    [0x04] = 'Next',
    [0x05] = 'Previous',
})
f.camera_playback_position = ProtoField.uint32 ("dji_dumlv1.camera_playback_position", "Seek Position (ms)", base.DEC)

-- Tap Zoom (0x79, 0x7A, 0x7B)
f.camera_tap_zoom_enable = ProtoField.uint8 ("dji_dumlv1.camera_tap_zoom_enable", "Tap Zoom Enable", base.HEX)
f.camera_tap_zoom_multiplier = ProtoField.uint8 ("dji_dumlv1.camera_tap_zoom_multiplier", "Tap Zoom Multiplier", base.DEC)
f.camera_tap_zoom_x = ProtoField.float ("dji_dumlv1.camera_tap_zoom_x", "Tap Zoom X (0-1)", nil)
f.camera_tap_zoom_y = ProtoField.float ("dji_dumlv1.camera_tap_zoom_y", "Tap Zoom Y (0-1)", nil)

-- ND Filter (0x84, 0x85)
f.camera_nd_filter = ProtoField.uint8 ("dji_dumlv1.camera_nd_filter", "ND Filter", base.HEX, {
    [0x00] = 'Clear',
    [0x01] = 'ND4',
    [0x02] = 'ND8',
    [0x03] = 'ND16',
    [0x04] = 'ND32',
    [0x05] = 'ND64',
    [0xFF] = 'Auto',
})

-- AE Lock (0x86, 0x87)
f.camera_ae_lock = ProtoField.uint8 ("dji_dumlv1.camera_ae_lock", "AE Lock", base.HEX, {[0]='Unlock', [1]='Lock'})

-- Mechanical Shutter (0x88, 0x89)
f.camera_mech_shutter_enable = ProtoField.uint8 ("dji_dumlv1.camera_mech_shutter_enable", "Mechanical Shutter", base.HEX, {[0]='Electronic', [1]='Mechanical'})

-- Defog (0x8A, 0x8B)
f.camera_defog_enable = ProtoField.uint8 ("dji_dumlv1.camera_defog_enable", "Defog Enable", base.HEX, {[0]='Off', [1]='On'})
f.camera_defog_strength = ProtoField.uint8 ("dji_dumlv1.camera_defog_strength", "Defog Strength", base.DEC)

-- Video Stream Source (0x90, 0x91)
f.camera_stream_source = ProtoField.uint8 ("dji_dumlv1.camera_stream_source", "Stream Source", base.HEX, {
    [0x00] = 'Wide Camera',
    [0x01] = 'Zoom Camera',
    [0x02] = 'Thermal Camera',
    [0x03] = 'IR Camera',
})

--------------------------------------------------------------------------------
-- Dissector functions for extended camera commands
--------------------------------------------------------------------------------

-- Camera Work Mode Set Dissector (0x10)
local function camera_work_mode_set_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 1 then
        subtree:add_le (f.camera_work_mode, payload(offset, 1))
        offset = offset + 1
    end
end

-- Photo Capture Dissector (0x01)
local function camera_photo_capture_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 1 then
        subtree:add_le (f.camera_photo_mode, payload(offset, 1))
        offset = offset + 1
    end
end

-- Video Record Dissector (0x02)
local function camera_video_record_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 1 then
        subtree:add_le (f.camera_record_mode, payload(offset, 1))
        offset = offset + 1
    end
end

-- Photo Format Dissector (0x12)
local function camera_photo_format_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 1 then
        subtree:add_le (f.camera_photo_format, payload(offset, 1))
        offset = offset + 1
    end
end

-- Video Format Dissector (0x18)
local function camera_video_format_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 1 then
        subtree:add_le (f.camera_video_format, payload(offset, 1))
        offset = offset + 1
    end
end

-- Exposure Mode Dissector (0x1E)
local function camera_exposure_mode_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 1 then
        subtree:add_le (f.camera_exposure_mode, payload(offset, 1))
        offset = offset + 1
    end
end

-- Metering Mode Dissector (0x22)
local function camera_metering_mode_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 1 then
        subtree:add_le (f.camera_metering_mode, payload(offset, 1))
        offset = offset + 1
    end
end

-- Focus Mode Dissector (0x24)
local function camera_focus_mode_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 1 then
        subtree:add_le (f.camera_focus_mode, payload(offset, 1))
        offset = offset + 1
    end
end

-- Aperture Dissector (0x26)
local function camera_aperture_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 2 then
        subtree:add_le (f.camera_aperture, payload(offset, 2))
        offset = offset + 2
    end
end

-- Shutter Speed Dissector (0x28)
local function camera_shutter_speed_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 4 then
        subtree:add_le (f.camera_shutter_reciprocal, payload(offset, 1))
        offset = offset + 1

        subtree:add_le (f.camera_shutter_time_s, payload(offset, 1))
        offset = offset + 1

        subtree:add_le (f.camera_shutter_time_sub, payload(offset, 2))
        offset = offset + 2
    end
end

-- ISO Dissector (0x2A)
local function camera_iso_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 4 then
        subtree:add_le (f.camera_iso_value, payload(offset, 4))
        offset = offset + 4
    end

    if payload:len() >= 5 then
        subtree:add_le (f.camera_iso_type, payload(offset, 1))
        offset = offset + 1
    end
end

-- White Balance Dissector (0x2C)
local function camera_white_balance_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 1 then
        subtree:add_le (f.camera_white_balance, payload(offset, 1))
        offset = offset + 1
    end

    if payload:len() >= 3 then
        subtree:add_le (f.camera_white_balance_kelvin, payload(offset, 2))
        offset = offset + 2
    end
end

-- Exposure Bias Dissector (0x2E)
local function camera_exposure_bias_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 1 then
        subtree:add_le (f.camera_exposure_bias, payload(offset, 1))
        offset = offset + 1
    end
end

-- Focus Region Dissector (0x30)
local function camera_focus_region_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 8 then
        subtree:add_le (f.camera_focus_region_x, payload(offset, 4))
        offset = offset + 4

        subtree:add_le (f.camera_focus_region_y, payload(offset, 4))
        offset = offset + 4
    end
end

-- Metering Region Dissector (0x32)
local function camera_metering_region_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 8 then
        subtree:add_le (f.camera_metering_region_x, payload(offset, 4))
        offset = offset + 4

        subtree:add_le (f.camera_metering_region_y, payload(offset, 4))
        offset = offset + 4
    end
end

-- Sharpness Dissector (0x38)
local function camera_sharpness_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 1 then
        subtree:add_le (f.camera_sharpness, payload(offset, 1))
        offset = offset + 1
    end
end

-- Contrast Dissector (0x3A)
local function camera_contrast_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 1 then
        subtree:add_le (f.camera_contrast, payload(offset, 1))
        offset = offset + 1
    end
end

-- Saturation Dissector (0x3C)
local function camera_saturation_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 1 then
        subtree:add_le (f.camera_saturation, payload(offset, 1))
        offset = offset + 1
    end
end

-- Anti-Flicker Dissector (0x46)
local function camera_anti_flicker_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 1 then
        subtree:add_le (f.camera_anti_flicker, payload(offset, 1))
        offset = offset + 1
    end
end

-- Burst Mode Dissector (0x48)
local function camera_burst_mode_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 1 then
        subtree:add_le (f.camera_burst_count, payload(offset, 1))
        offset = offset + 1
    end
end

-- Interval Timer Dissector (0x4A)
local function camera_interval_timer_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 3 then
        subtree:add_le (f.camera_interval_count, payload(offset, 1))
        offset = offset + 1

        subtree:add_le (f.camera_interval_seconds, payload(offset, 2))
        offset = offset + 2
    end
end

-- Focus Parameter Dissector (0x52)
local function camera_focus_param_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 1 then
        subtree:add_le (f.camera_focus_ctrl_mode, payload(offset, 1))
        offset = offset + 1
    end

    if payload:len() >= 11 then
        subtree:add_le (f.camera_focus_x, payload(offset, 4))
        offset = offset + 4

        subtree:add_le (f.camera_focus_y, payload(offset, 4))
        offset = offset + 4

        subtree:add_le (f.camera_focus_distance, payload(offset, 2))
        offset = offset + 2
    end
end

-- Zoom Parameter Dissector (0x53)
local function camera_zoom_param_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 4 then
        subtree:add_le (f.camera_zoom_mode, payload(offset, 1))
        offset = offset + 1

        subtree:add_le (f.camera_zoom_speed, payload(offset, 1))
        offset = offset + 1

        subtree:add_le (f.camera_zoom_focal_length, payload(offset, 2))
        offset = offset + 2
    end
end

-- SD Card Info Dissector (0x71)
local function camera_sd_card_info_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 1 then
        subtree:add_le (f.camera_sd_inserted, payload(offset, 1))
        offset = offset + 1
    end

    if payload:len() >= 17 then
        subtree:add_le (f.camera_sd_total_mb, payload(offset, 4))
        offset = offset + 4

        subtree:add_le (f.camera_sd_free_mb, payload(offset, 4))
        offset = offset + 4

        subtree:add_le (f.camera_sd_photo_count, payload(offset, 4))
        offset = offset + 4

        subtree:add_le (f.camera_sd_video_seconds, payload(offset, 4))
        offset = offset + 4
    end
end

-- Format SD Card Dissector (0x72)
local function camera_format_sd_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 1 then
        subtree:add_le (f.camera_format_slow, payload(offset, 1))
        offset = offset + 1
    end
end

-- Video Playback Control Dissector (0x7A)
local function camera_playback_ctrl_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 1 then
        subtree:add_le (f.camera_playback_cmd, payload(offset, 1))
        offset = offset + 1
    end

    if payload:len() >= 5 then
        subtree:add_le (f.camera_playback_position, payload(offset, 4))
        offset = offset + 4
    end
end

-- Video Stream Source Dissector (0x90)
local function camera_stream_source_dissector(pkt_length, buffer, pinfo, subtree)
    local offset = 11
    local payload = buffer(offset, pkt_length - offset - 2)
    offset = 0

    if payload:len() >= 1 then
        subtree:add_le (f.camera_stream_source, payload(offset, 1))
        offset = offset + 1
    end
end

--------------------------------------------------------------------------------
-- Register extended dissectors to the main CAMERA_UART_CMD_DISSECT table
--------------------------------------------------------------------------------

if CAMERA_UART_CMD_DISSECT then
    -- Basic commands
    CAMERA_UART_CMD_DISSECT[0x01] = camera_photo_capture_dissector
    CAMERA_UART_CMD_DISSECT[0x02] = camera_video_record_dissector

    -- Mode commands
    CAMERA_UART_CMD_DISSECT[0x10] = camera_work_mode_set_dissector
    CAMERA_UART_CMD_DISSECT[0x11] = camera_work_mode_set_dissector  -- Get uses same format

    -- Format commands
    CAMERA_UART_CMD_DISSECT[0x12] = camera_photo_format_dissector
    CAMERA_UART_CMD_DISSECT[0x13] = camera_photo_format_dissector
    CAMERA_UART_CMD_DISSECT[0x18] = camera_video_format_dissector
    CAMERA_UART_CMD_DISSECT[0x19] = camera_video_format_dissector

    -- Exposure commands
    CAMERA_UART_CMD_DISSECT[0x1E] = camera_exposure_mode_dissector
    CAMERA_UART_CMD_DISSECT[0x1F] = camera_exposure_mode_dissector
    CAMERA_UART_CMD_DISSECT[0x22] = camera_metering_mode_dissector
    CAMERA_UART_CMD_DISSECT[0x23] = camera_metering_mode_dissector
    CAMERA_UART_CMD_DISSECT[0x26] = camera_aperture_dissector
    CAMERA_UART_CMD_DISSECT[0x27] = camera_aperture_dissector
    CAMERA_UART_CMD_DISSECT[0x28] = camera_shutter_speed_dissector
    CAMERA_UART_CMD_DISSECT[0x29] = camera_shutter_speed_dissector
    CAMERA_UART_CMD_DISSECT[0x2A] = camera_iso_dissector
    CAMERA_UART_CMD_DISSECT[0x2B] = camera_iso_dissector
    CAMERA_UART_CMD_DISSECT[0x2C] = camera_white_balance_dissector
    CAMERA_UART_CMD_DISSECT[0x2D] = camera_white_balance_dissector
    CAMERA_UART_CMD_DISSECT[0x2E] = camera_exposure_bias_dissector
    CAMERA_UART_CMD_DISSECT[0x2F] = camera_exposure_bias_dissector

    -- Focus commands
    CAMERA_UART_CMD_DISSECT[0x24] = camera_focus_mode_dissector
    CAMERA_UART_CMD_DISSECT[0x25] = camera_focus_mode_dissector
    CAMERA_UART_CMD_DISSECT[0x30] = camera_focus_region_dissector
    CAMERA_UART_CMD_DISSECT[0x31] = camera_focus_region_dissector
    CAMERA_UART_CMD_DISSECT[0x32] = camera_metering_region_dissector
    CAMERA_UART_CMD_DISSECT[0x33] = camera_metering_region_dissector
    CAMERA_UART_CMD_DISSECT[0x52] = camera_focus_param_dissector
    CAMERA_UART_CMD_DISSECT[0x53] = camera_zoom_param_dissector

    -- Image quality commands
    CAMERA_UART_CMD_DISSECT[0x38] = camera_sharpness_dissector
    CAMERA_UART_CMD_DISSECT[0x39] = camera_sharpness_dissector
    CAMERA_UART_CMD_DISSECT[0x3A] = camera_contrast_dissector
    CAMERA_UART_CMD_DISSECT[0x3B] = camera_contrast_dissector
    CAMERA_UART_CMD_DISSECT[0x3C] = camera_saturation_dissector
    CAMERA_UART_CMD_DISSECT[0x3D] = camera_saturation_dissector
    CAMERA_UART_CMD_DISSECT[0x46] = camera_anti_flicker_dissector
    CAMERA_UART_CMD_DISSECT[0x47] = camera_anti_flicker_dissector

    -- Capture mode commands
    CAMERA_UART_CMD_DISSECT[0x48] = camera_burst_mode_dissector
    CAMERA_UART_CMD_DISSECT[0x49] = camera_burst_mode_dissector
    CAMERA_UART_CMD_DISSECT[0x4A] = camera_interval_timer_dissector
    CAMERA_UART_CMD_DISSECT[0x4B] = camera_interval_timer_dissector

    -- Storage commands
    CAMERA_UART_CMD_DISSECT[0x71] = camera_sd_card_info_dissector
    CAMERA_UART_CMD_DISSECT[0x72] = camera_format_sd_dissector

    -- Playback commands
    CAMERA_UART_CMD_DISSECT[0x7A] = camera_playback_ctrl_dissector

    -- Stream commands
    CAMERA_UART_CMD_DISSECT[0x90] = camera_stream_source_dissector
    CAMERA_UART_CMD_DISSECT[0x91] = camera_stream_source_dissector

    print("DJI DUMLv1 Camera Extension: Added 42 new dissectors")
else
    print("Warning: CAMERA_UART_CMD_DISSECT not found - Camera extension not loaded")
end

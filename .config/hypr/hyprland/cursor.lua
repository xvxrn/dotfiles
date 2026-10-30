local THEME = "Bibata-Modern-Classic"
local BASE = 24
local BIG = 72
local SLIDE = 8
local FLIPS = 4
local SPAN = 10
local HOLD = 14
local TICK = 50

local tick = 0
local last_x = nil
local last_sign = 0
local flip_first = 0
local flip_count = 0
local hold_until = -1
local current = BASE

local function setsize(size)
    if size ~= current then
        current = size
        hl.exec_cmd("hyprctl setcursor " .. THEME .. " " .. size)
    end
end

local function step()
    tick = tick + 1

    if hold_until >= 0 and tick >= hold_until then
        setsize(BASE)
        hold_until = -1
        last_sign = 0
        flip_count = 0
        return
    end

    local pos = hl.get_cursor_pos()
    if not pos then
        return
    end

    if last_x == nil then
        last_x = pos.x
        return
    end

    local dx = pos.x - last_x
    last_x = pos.x

    if hold_until >= 0 or math.abs(dx) < SLIDE then
        return
    end

    local sign = dx < 0 and -1 or 1
    if sign == last_sign then
        return
    end
    last_sign = sign

    if flip_count == 0 or tick - flip_first > SPAN then
        flip_first = tick
        flip_count = 1
        return
    end

    flip_count = flip_count + 1

    if flip_count >= FLIPS then
        flip_count = 0
        setsize(BIG)
        hold_until = tick + HOLD
    end
end

hl.timer(step, { timeout = TICK, type = "repeat" })

-- 消息
hmessage = {}

-- 在屏幕打印信息给所有玩家
hmessage.echo = function(msg, duration)
    for i = 0, bj_MAX_PLAYERS - 1, 1 do
        if (duration == nil or duration < 5) then
            cj.DisplayTextToPlayer(cj.Player(i), 0, 0, msg)
        else
            cj.DisplayTimedTextToPlayer(cj.Player(i), 0, 0, duration, msg)
        end
    end
end
-- 在屏幕(x,y)处打印信息给某玩家
hmessage.echoXY = function(whichPlayer, msg, x, y, duration)
    if (duration == nil or duration < 5) then
        cj.DisplayTextToPlayer(whichPlayer, x, y, msg)
    else
        cj.DisplayTimedTextToPlayer(whichPlayer, x, y, duration, msg)
    end
end
-- 在屏幕(0.0)处打印信息给某玩家
hmessage.echo00 = function(whichPlayer, msg, duration)
    hmessage.echoXY(whichPlayer, msg, 0, 0, duration)
end

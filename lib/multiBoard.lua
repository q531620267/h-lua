-- [[多面板/多列榜]]
local hmultiBoard = {}

--[[
    根据玩家创建多面板,多面板是可以每个玩家看到的都不一样的
    key 多面板唯一key
    refreshFrequency 刷新频率
    yourData 设置数据的回调,会返回当前的多面板和玩家索引；
             另外你需要设置数据传回到create中来，拼凑多面板数据，二维数组，行列模式
]]
hmultiBoard.create = function(key, refreshFrequency, yourData)
    --判断玩家各自的多面板属性
    for pi = 1, hplayer.qty_max, 1 do
        local p = hplayer.players[pi]
        if (his.playing(p)) then
            if (hRuntime.multiBoard[pi] == nil) then
                hRuntime.multiBoard[pi] = {
                    visible = true,
                    timer = nil,
                    borads = {}
                }
            end
            if (hRuntime.multiBoard[pi].borads[key] ~= nil) then
                cj.DestroyMultiboard(hRuntime.multiBoard[pi].borads[key])
            end
            hRuntime.multiBoard[pi].borads[key] = cj.CreateMultiboard()
            --title
            cj.MultiboardSetTitleText(hRuntime.multiBoard[pi].borads[key], "多面板")
            --
            hRuntime.multiBoard[pi].timer =
                htime.setInterval(
                refreshFrequency,
                function(t, td)
                    --检查玩家是否隐藏了多面板 -mbv
                    if (hRuntime.multiBoard[pi].visible ~= true) then
                        if (cj.GetLocalPlayer() == p) then
                            cj.MultiboardDisplay(hRuntime.multiBoard[pi].borads[key], false)
                        end
                        --而且隐藏就没必要展示数据了，后续流程中止
                        return
                    end
                    local data = yourData(hRuntime.multiBoard[pi].borads[key], pi)
                    local totalRow = #data
                    local totalCol = 0
                    if (totalRow > 0) then
                        totalCol = #data[1]
                    end
                    print_mbr(data)
                    if (totalRow <= 0 or totalCol <= 0) then
                        print_err("Multiboard:-totalRow -totalCol")
                        return
                    end
                    --设置行列数
                    cj.MultiboardSetRowCount(hRuntime.multiBoard[pi].borads[key], totalRow)
                    cj.MultiboardSetColumnCount(hRuntime.multiBoard[pi].borads[key], totalCol)
                    for row = 1, totalRow, 1 do
                        for col = 1, totalCol, 1 do
                            local item = cj.MultiboardGetItem(hRuntime.multiBoard[pi].borads[key], row - 1, col - 1)
                            local isSetValue = false
                            local isSetIcon = false
                            local width = 0
                            if (data[row][col].value ~= nil) then
                                isSetValue = true
                                cj.MultiboardSetItemValue(item, data[row][col].value)
                                width = width + string.mb_len(data[row][col].value)
                            end
                            if (data[row][col].icon ~= nil) then
                                isSetIcon = true
                                cj.MultiboardSetItemIcon(item, data[row][col].icon)
                                width = width + 1
                            end
                            print("width=" .. col .. "/" .. width)
                            cj.MultiboardSetItemStyle(item, isSetValue, isSetIcon)
                            cj.MultiboardSetItemWidth(item, width / 100)
                        end
                    end
                    --显示
                    if (cj.GetLocalPlayer() == p) then
                        cj.MultiboardDisplay(hRuntime.multiBoard[pi].borads[key], true)
                    end
                end
            )
        end
    end
end

return hmultiBoard

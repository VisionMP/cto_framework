CreateThread(function()
    while true do
        Wait(0)

        local player = PlayerPedId()
        local pCoords = GetEntityCoords(player)
        local pedList = GetGamePool("CPed")

        for _, ped in ipairs(pedList) do
            if not IsPedAPlayer(ped) then

                -- Only check nearby peds (performance)
                if #(GetEntityCoords(ped) - pCoords) < 50.0 then

                    -- Detect taser hit
                    if IsPedBeingStunned(ped, 0) then

                        -- Restore ped to exactly 100 HP
                        SetEntityHealth(ped, 100)

                        -- Clear tasks so they don't run or fight
                        ClearPedTasksImmediately(ped)

                        -- Force ragdoll
                        SetPedToRagdoll(ped, 3000, 3000, 0, false, false, false)
                    end
                end
            end
        end
    end
end)

CreateThread(function()
    while true do
        Wait(0)

        -- Force-enable EMS AI
        EnableDispatchService(5, true)  -- Ambulance
        EnableDispatchService(6, true)  -- Fire/EMS backup

        -- Make sure medics can revive and pick up bodies
        SetCreateRandomCops(false)
        SetCreateRandomCopsNotOnScenarios(false)
        SetCreateRandomCopsOnScenarios(false)
    end
end)

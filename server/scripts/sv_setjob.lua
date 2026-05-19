local jobCooldown = {}
local JOB_COOLDOWN_TIME = 600 -- 10 minutes

RegisterCommand("setjob", function(source, args)
    local player = source
    --local xPlayer = exports['cto_framework']:getDataObject()

    if not args[1] then
        TriggerClientEvent("chat:addMessage", player, {
            args = { "[Jobs]", "Usage: /setjob <police | dealer>" }
        })
        return
    end

    -- Map input → actual job name PD5M expects
    local allowedJobs = {
        ["police"] = "Police Officer",
        ["tow"] = "Tow Driver",
        ["car"] = "Car Dealer",
        ["dealer"] = "Dealer"

    }

    local input = string.lower(args[1])
    local newJob = allowedJobs[input]

    if not newJob then
        TriggerClientEvent("chat:addMessage", player, {
            args = { "[Jobs]", "Invalid job. Allowed: police, dealer" }
        })
        return
    end

    -- Cooldown check
    local now = os.time()
    if jobCooldown[player] and jobCooldown[player] > now then
        local remaining = jobCooldown[player] - now
        TriggerClientEvent("chat:addMessage", player, {
            args = { "[Jobs]", "You must wait " .. remaining .. " seconds before changing jobs again." }
        })
        return
    end

    jobCooldown[player] = now + JOB_COOLDOWN_TIME

    -- Set job using your CTO framework
    CTO.Job.Set(player, newJob)

    TriggerClientEvent("chat:addMessage", player, {
        args = { "[Jobs]", "Your job has been changed to: " .. newJob }
    })

end)
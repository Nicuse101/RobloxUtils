webhookManager = {}
request = http_request or request or HttpPost or (syn and syn.request)

function webhookManager:checkSupport()
    return type(request) == "function"
end

function webhookManager:checkWebhook(webhook_url)
    local headers = {["Content-Type"]="application/json"}
    local data = {Url = webhook_url, Method = "GET", Headers = headers}
    local response = request(data)

    return response.Success, response.Body
end

function webhookManager:createField(name, value, inline)
    inline = inline or true
    return {
        ["name"] = name,
        ["value"] = value,
        ["inline"] = inline
    }    
end

function webhookManager:createImageOrThumbnail(url)
    return {["url"] = url}
end

function webhookManager:createFooter(text, icon_url)
    return {["text"] = text, ["icon_url"] = icon_url}
end

function webhookManager:createAuthor(name, url, icon_url)
    return {
        ["name"] = name,
        ["url"] = url,
        ["icon_url"] = icon_url
    }
end

-- title, description, color, url, author, fields, footer, image, thumbnail, timestamp
function webhookManager:createEmbed(args)
    local embed = {}
    for i, v in pairs(args) do
        embed[i] = v
    end
    return embed
end

function webhookManager:sendPostRequest(webhook_url, request_data)
    local headers = {["Content-Type"]="application/json"}
    local json = game:GetService("HttpService"):JSONEncode(request_data)
    local data = {Url = webhook_url, Body = json, Method = "POST", Headers = headers}
    local response = request(data)

    return response.Success, response.Body
end

return webhookManager

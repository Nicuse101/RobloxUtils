for _, functionName in {...} do
    local func = getgenv and rawget(getgenv(), functionName)
    if type(func) ~= "function" then
        return false
    end
end
return true

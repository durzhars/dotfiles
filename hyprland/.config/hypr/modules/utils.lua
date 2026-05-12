local M = {}
function M.create_bind(spec)
    local handles = {}
    for i, key_data in ipairs(spec.keys) do
        local action = spec.exec[i]
        if not action then
            break
        end
        local action_to_bind
        if type(action) == "table" and (type(action[1]) == "table" or type(action[1]) == "function") then
            action_to_bind = function()
                for _, item in ipairs(action) do
                    if type(item) == "table" and type(item[1]) == "function" then
                        hl.dispatch(item[1](item[2]))
                    else
                        hl.dispatch(item)
                    end
                end
            end
        else
            if type(action) == "table" and type(action[1]) == "function" then
                action_to_bind = function()
                    hl.dispatch(action[1](action[2]))
                end
            else
                action_to_bind = action
            end
        end
        local keys_to_bind = type(key_data) == "table" and key_data or { key_data }
        local opts = spec.opts or {}
        for _, key in ipairs(keys_to_bind) do
            table.insert(handles, hl.bind(key, action_to_bind, opts))
        end
    end
    return handles
end

return M

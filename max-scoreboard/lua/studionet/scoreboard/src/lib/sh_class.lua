local Addon = StudioNetworkScoreboard

----------------------------------------------------------------

local pairs = pairs
local type = type
local setmetatable = setmetatable

----------------------------------------------------------------

--[[
- Copies a table.
-
- @param table origin - The table to copy from
- @param table|nil target - The table to copy in to
-
- @return table
]]
function copy(origin, target)
    target = target == nil and {} or target

	for key, value in pairs(origin) do
        target[key] = value
	end

	return target
end

--[[
- Deep copies a table.
-
- @param table origin - The table to copy from
- @param table|nil target - The table to copy in to
- @param table|nil references - Table that keeps track of reoccuring tables
-
- @return table
]]
local deepCopy
function deepCopy(origin, target, references)
    target = target == nil and {} or target
	references = references == nil and {} or references

	for key, value in pairs(origin) do

		if type(key) == 'table' then

            if references[key] ~= nil then
                key = references[key]
            else

    			local copy = {}
    			references[key] = copy

    			key = deepCopy(key, copy, references)

            end

		end

		if type(value) == 'table' then

            if references[value] ~= nil then
                value = references[value]
            else

    			local copy = {}
    			references[value] = copy

    			value = deepCopy(value, copy, references)

            end

		end

		target[key] = value

	end

	return target
end

----------------------------------------------------------------

--[[
-
]]
local function __newInstance(self, ...)
	local instance = setmetatable({}, self.__prototype)

    if instance.__construct ~= nil then
        instance:__construct(...)
    end

	return instance
end

--[[
- Creates a new class table.
-
- @param table|function|nil extends
- @param table|function|nil table
- @param function|nill callback=nil
-
- @return table
]]
function Addon.class(extends, table, callback)

	if type(extends) == 'function' then
		extends, table, callback = nil, nil, extends
	elseif type(table) == 'function' then
		extends, table, callback = extends, nil, table
    end

    -- Create the new class table
	local class
	if extends == nil then
        if table == nil then
            class = {

    			__parent = nil,
    			__prototype = {
                    __parent = nil
                },

                new = __newInstance

    		}
        else
            class = table
        end
	else
		class = deepCopy(extends, table)
	end

    if class.__prototype == nil then
        error("Not a valid class.")
    end

    -- Set the '__parent' property..
    if extends ~= nil then
        class.__parent = extends
    	class.__prototype.__parent = class.__parent.__prototype
    end

    class.__prototype.__index = class.__prototype

    -- Initialize the class
	if callback ~= nil then
		callback(class, class.__prototype)
	end

	return class
end

-- class function - enables pseudo-oop with inheritance using metatables
function class(baseClass)
    local classObject = {}

    -- create copies of the base class' methods
    if type(baseClass) == 'table' then
        for key, value in pairs(baseClass) do
            classObject[key] = value
        end
        classObject._base = baseClass
    end

    -- expose a constructor which can be called by <classname>(<args>)
    local metaTable = {}
    metaTable.__call = function(self, ...)
        local classInstance = {}
        setmetatable(classInstance, classObject)
        if self.construct then
            self.construct(classInstance, ...)
        else
            -- at least call the base class' constructor
            if baseClass and baseClass.construct then
                baseClass.construct(classInstance, ...)
            end
        end

        return classInstance
    end

    classObject.IsInstanceOf = function(self, compareClass)
        local metaTable = getmetatable(self)
        while metaTable do
            if metaTable == compareClass then return true end
            metaTable = metaTable._base
        end
        return false
    end

    classObject.AssertArgumentType = function(argValue, argType)
        if (type(argType) == 'table') and type(argType.IsInstanceOf) == 'function' then
            assert((type(argValue) == 'table') and type(argValue.IsInstanceOf) == 'function' and argValue:IsInstanceOf(argType), 'argument is not an instance of the expected class')
        elseif type(argType) == 'string' then
            assert(type(argValue) == argType, argType..' expected, got '..type(argValue))
        else
            error("AssertArgumentType: argType is expected to be a string or class object")
        end
    end

    -- prepare metatable for lookup of our instance's functions
    classObject.__index = classObject
    setmetatable(classObject, metaTable)
    return classObject
end

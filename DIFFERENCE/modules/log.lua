---@class Log
---@field category string
local LogMeta = {}
LogMeta.__index = LogMeta

---@return Log
function Log(category)
	return setmetatable({category = category}, LogMeta)
end

-- Пишет ошибку со стеком в лог ошибок. Принимает строку с форматированием, перенос строки не нужен.
function LogMeta:Error(template, ...)
	-- Перенос строки в конце не нужен.
	ErrorNoHaltWithStack("[", self.category, "] ", template:format(...))
end

-- Пишет ошибку без стека в лог ошибок. Принимает строку с форматированием, перенос строки не нужен.
function LogMeta:ErrorNoStack(template, ...)
	-- Необходимо в начале дополнить скобками для соответствия другим ошибкам.
	ErrorNoHalt("[ERROR] [", self.category, "] ", template:format(...), "\n")
end

-- Пишет информационное сообщение в обычный лог. Принимает строку с форматированием, перенос строки не нужен.
function LogMeta:Info(template, ...)
	Msg("[INFO] [", self.category, "] ", template:format(...), "\n")
end

-- Пишет информационное сообщение в указанный файл. Принимает строку с форматированием, перенос строки не нужен.
function LogMeta:InfoToFile(filename, template, ...)
	local message = {os.date("%Y-%m-%d %H:%M:%S: "), "[INFO] [", self.category, "] ", template:format(...), "\n"}
	PBE.Append(filename, table.concat(message))
end

-- Вывод всех аргументов через print (tostring). Не попадает в лог ошибок. Пустые аргументы `nil` сохраняются как есть.
function LogMeta:Dump(...)
	print("[DUMP] [" .. self.category .. "]", ...)
end

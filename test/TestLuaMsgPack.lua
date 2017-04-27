local mpack = require("MessagePack")
local pack, upack = mpack.pack, mpack.unpack

---output in hex
function print_hex(buffer, num)
	local str = ''
	local cnt = 0
	for idx = 1, num or #buffer do
		for kdx = 1, #buffer[idx] do
			str = str .. string.format("%X",buffer[idx]:sub(kdx):byte()) .. ' '
			cnt = cnt + 1
		end
	end
	print(str)
end

function print_table(t, level, leadSpace)
    level = level or 1

    local rlt = ""
    for idx = 1, leadSpace do
        rlt = rlt .. " "
    end

    local blacnSpace = rlt

    local len = #t
    for k, v in pairs(t) do
        if type(k) == "number" then
            rlt = rlt .. "[" .. k .. "]"
        elseif type(k) == "string" then
            rlt = rlt .. '["' .. k .. '"]'
        end

        if type(v) == "table" then
            if level > 0  then
                rlt = rlt .. " = {\n" .. print_table(v, level - 1, leadSpace + 4) .. "\n" .. blacnSpace .. "}, "
            else
                rlt = rlt .. " = {" .. print_table(v, level - 1, 0) .. "}, "
            end
        elseif type(v) == "string" then
            rlt = rlt .. ' = "' .. v .. '", '
        else
            rlt = rlt .. ' = ' .. tostring(v) .. ', '
        end

        if level >= 0 then
            rlt = rlt .. '\n' .. blacnSpace
        end

    end

    return rlt
end

function test(v)
	local buffer, rlt = pack(v)
	print("----------------\npack:", v)
	print_hex(buffer)

	local rlt = upack(rlt)
	print("unpack:")
	if type(rlt) ~= 'table' then
		print(rlt, '\n----------------')
	else
		local str, cnt = print_table(rlt, 3, 1)
		print(str, '\n----------------', cnt)
	end
end

---test nil, boolean
test(nil)
test(true)
test(false)

---test number, include int8/16/32/64,uint/8/16/32/64, fix pos, fix neg, float, double
math.randomseed(os.time())
for i = 1, 10 do
	local v = math.random(0, 255)
	test(v)
end

test(127)		--fix pos
test(128)		--uint 8
test(0xFF-1)	--uint 8
test(0xFF)		--uint 8
test(0xFF+1)	--uint 16
test(0xFFFF)	--uint 16
test(0xFFFFFFFF)--uint 32
test(4294967296)--uint 64, 	错误, 貌似0x100000000
-- test(9007199254740991)

--test special value, include inf、-inf、Nan
test(1.0/0.0)
test(-1.0/0.0)
test(0.0/0.0)

---test table(array & map)
mpack.set_array("with_hole")
test({1, 2, 3, 4, 'x', 'y','z'})
test({})
test({x = 1, y = 2, z = 3, {4, 5, 6}})
test({[1] = 'x' ,[2] = 'y', [4] = 'z'})
test({1, 2, 3, nil})

local t = {3, 2, 1, [4] = nil}
test(t)
for k, v in pairs(t) do
	print(k, v)
end
print(#t)

local t1 = {x = nil, y = 1}
local t2 = {z = t1}
t1['x'] = t2
-- test(t2) -- the same as test(t1), could be stack overflow

---test string

mpack.set_string("string_compat")
test("")
test(" ")
test("1234567891234567891234567891234")	--fixstr
test("12345678912345678912345678912345") --str8

mpack.set_string("string")

--test({500026, 155, {__entity_id = 500026 , __gate_id = 2, __server_id = 5, __type = "Player"}})

--test({500026, 93, {autoMatchGoal = 0, autoMatchPlayerNum = 0, autoMatchTeamNum = 0, teams = {}}})
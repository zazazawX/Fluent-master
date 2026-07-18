--!strict

local StressTest = {}

export type Result = {
	Count: number,
	CreateSeconds: number,
	SignalDelta: number,
	RegistryDelta: number,
	OptionsDelta: number,
	MemoryDeltaKB: number,
	OptionsRemaining: number,
}

local function CountEntries(Source: any): number
	local Count = 0
	for _ in next, Source do
		Count += 1
	end
	return Count
end

local function GetMemory(): number
	local Success, Value = pcall(function()
		return collectgarbage("count")
	end)
	return Success and Value or 0
end

function StressTest.Run(Tab: any, Library: any, FluentModule: ModuleScript, RequestedCount: number?): Result
	local Count = math.clamp(math.floor(RequestedCount or 100), 1, 500)
	local Creator = require(FluentModule.Creator)
	local SignalsBefore = #Creator.Signals
	local RegistryBefore = CountEntries(Creator.Registry)
	local OptionsBefore = CountEntries(Library.Options)
	local MemoryBefore = GetMemory()
	local StartedAt = os.clock()
	local Created = {}

	for Index = 1, Count do
		local Id = "Stress_" .. tostring(Index)
		local Kind = Index % 3
		if Kind == 0 then
			table.insert(Created, Tab:AddButton({
				Title = "Stress button " .. tostring(Index),
				Callback = function() end,
			}))
		elseif Kind == 1 then
			table.insert(Created, Tab:AddToggle(Id, {
				Title = "Stress toggle " .. tostring(Index),
				Default = Index % 2 == 0,
			}))
		else
			table.insert(Created, Tab:AddSlider(Id, {
				Title = "Stress slider " .. tostring(Index),
				Default = Index % 100,
				Min = 0,
				Max = 100,
				Rounding = 0,
			}))
		end
	end

	task.wait()
	local CreateSeconds = os.clock() - StartedAt
	for _, Object in ipairs(Created) do
		Object:Destroy()
	end
	task.wait()

	return {
		Count = Count,
		CreateSeconds = CreateSeconds,
		SignalDelta = #Creator.Signals - SignalsBefore,
		RegistryDelta = CountEntries(Creator.Registry) - RegistryBefore,
		OptionsDelta = CountEntries(Library.Options) - OptionsBefore,
		MemoryDeltaKB = GetMemory() - MemoryBefore,
		OptionsRemaining = CountEntries(Library.Options),
	}
end

return StressTest

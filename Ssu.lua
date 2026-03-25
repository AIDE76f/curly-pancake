--[[ 
    THE BASE RAIDER V4 - SMART COLLECTION
    - يسرق فقط من القواعد المفتوحة (Open Gates Only)
    - يتجاهل أشياء الروبوكس تماماً
    - تحسين توقيت الجمع لتجاوز حماية الـ 1 ثانية
]]

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local ToggleBtn = Instance.new("TextButton")
local StatusLabel = Instance.new("TextLabel")

-- تصميم الواجهة
ScreenGui.Parent = game.CoreGui
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 240, 0, 140)
MainFrame.Position = UDim2.new(0.1, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Active = true
MainFrame.Draggable = true

ToggleBtn.Parent = MainFrame
ToggleBtn.Size = UDim2.new(0.9, 0, 0.4, 0)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
ToggleBtn.Text = "START RAIDING BASES"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.Font = Enum.Font.GothamBold

StatusLabel.Parent = MainFrame
StatusLabel.Size = UDim2.new(1, 0, 0, 30)
StatusLabel.Position = UDim2.new(0, 0, 0.7, 0)
StatusLabel.Text = "Status: Waiting for Open Base"
StatusLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)

local isRunning = false
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- دالة للتحقق هل القاعدة مفتوحة؟
local function isBaseAccessible(item)
    local baseFolder = item:FindFirstAncestor("Base") or item:FindFirstAncestorWhichIsA("Model")
    if baseFolder then
        -- البحث عن باب أو ليزر حماية (Gate / Laser / Door)
        local gate = baseFolder:FindFirstChild("Gate") or baseFolder:FindFirstChild("Door")
        if gate then
            -- إذا كان الباب شفافاً أو ملغياً، فالقاعدة مفتوحة
            if gate.CanCollide == false or gate.Transparency > 0.5 then
                return true
            end
            return false -- القاعدة مغلقة
        end
    end
    return true -- إذا لم يجد باباً، نفترض أنها مفتوحة
end

ToggleBtn.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    ToggleBtn.Text = isRunning and "STOP RAIDING" or "START RAIDING"
    ToggleBtn.BackgroundColor3 = isRunning and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(0, 200, 100)
    
    task.spawn(function()
        while isRunning do
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("TouchTransmitter") then
                    local target = obj.Parent
                    
                    -- الفلترة: 1. آمن من الموت | 2. قاعدة مفتوحة | 3. ليس روبوكس
                    if target and isBaseAccessible(target) and not target:FindFirstChild("ProductValue") then
                        
                        -- تنفيذ اللمس (مرة واحدة كل 0.1 ثانية لمحاكاة الإنتاج السريع)
                        pcall(function()
                            firetouchinterest(character.HumanoidRootPart, target, 0)
                            task.wait()
                            firetouchinterest(character.HumanoidRootPart, target, 1)
                        end)
                    end
                end
            end
            task.wait(0.1) -- السرعة القصوى المسموح بها لتجنب الكشف
            StatusLabel.Text = "Status: Scanning & Collecting..."
        end
        StatusLabel.Text = "Status: Idle"
    end)
end)

local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local gameFrame = Instance.new("Frame")
gameFrame.Size = UDim2.new(0, 400, 0, 400)
gameFrame.Position = UDim2.new(0.5, -200, 0.5, -200)
gameFrame.BackgroundColor3 = Color3.new(0, 0, 0)
gameFrame.Parent = screenGui

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 50, 0, 50)
closeButton.Position = UDim2.new(1, -55, 0, 5)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.BackgroundColor3 = Color3.new(1, 0, 0)
closeButton.Parent = gameFrame

local dragging = false
local dragInput, mousePos, framePos

gameFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        mousePos = input.Position
        framePos = gameFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

gameFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - mousePos
        gameFrame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
    end
end)

local cellSize = 20
local snake = {}
local direction = "Right"
local food
local gameActive = true

local function initializeSnake()
    for _, part in ipairs(snake) do
        part:Destroy()
    end
    snake = {}

    for i = 1, 3 do
        local part = Instance.new("Frame")
        part.Size = UDim2.new(0, cellSize, 0, cellSize)
        part.Position = UDim2.new(0, (4 - i) * cellSize, 0, 0)
        part.BackgroundColor3 = Color3.new(0, 1, 0)
        part.Parent = gameFrame
        table.insert(snake, part)
    end
    direction = "Right"
end

initializeSnake()

local function createFood()
    if food then food:Destroy() end
    food = Instance.new("Frame")
    food.Size = UDim2.new(0, cellSize, 0, cellSize)
    food.BackgroundColor3 = Color3.new(1, 0, 0)
    food.Position = UDim2.new(0, math.random(0, (gameFrame.Size.X.Offset / cellSize) - 1) * cellSize, 0, math.random(0, (gameFrame.Size.Y.Offset / cellSize) - 1) * cellSize)
    food.Parent = gameFrame
end
createFood()

local function moveSnake()
    local head = snake[1]
    local newHeadPosition
    if direction == "Right" then
        newHeadPosition = UDim2.new(head.Position.X.Scale, head.Position.X.Offset + cellSize, head.Position.Y.Scale, head.Position.Y.Offset)
    elseif direction == "Left" then
        newHeadPosition = UDim2.new(head.Position.X.Scale, head.Position.X.Offset - cellSize, head.Position.Y.Scale, head.Position.Y.Offset)
    elseif direction == "Up" then
        newHeadPosition = UDim2.new(head.Position.X.Scale, head.Position.X.Offset, head.Position.Y.Scale, head.Position.Y.Offset - cellSize)
    elseif direction == "Down" then
        newHeadPosition = UDim2.new(head.Position.X.Scale, head.Position.X.Offset, head.Position.Y.Scale, head.Position.Y.Offset + cellSize)
    end

    if newHeadPosition.X.Offset < 0 or newHeadPosition.X.Offset >= gameFrame.Size.X.Offset or
       newHeadPosition.Y.Offset < 0 or newHeadPosition.Y.Offset >= gameFrame.Size.Y.Offset then
        initializeSnake()
        createFood()
        return
    end

    for i = 2, #snake do
        if snake[i].Position == newHeadPosition then
            initializeSnake()
            createFood()
            return
        end
    end

    if head.Position == food.Position then
        food:Destroy()
        createFood()

        local newPart = Instance.new("Frame")
        newPart.Size = UDim2.new(0, cellSize, 0, cellSize)
        newPart.BackgroundColor3 = Color3.new(0, 1, 0)
        newPart.Position = snake[#snake].Position
        newPart.Parent = gameFrame
        table.insert(snake, newPart)
    end

    for i = #snake, 2, -1 do
        snake[i].Position = snake[i-1].Position
    end
    snake[1].Position = newHeadPosition
end

game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.W and direction ~= "Down" then
        direction = "Up"
    elseif input.KeyCode == Enum.KeyCode.S and direction ~= "Up" then
        direction = "Down"
    elseif input.KeyCode == Enum.KeyCode.A and direction ~= "Right" then
        direction = "Left"
    elseif input.KeyCode == Enum.KeyCode.D and direction ~= "Left" then
        direction = "Right"
    end
end)

spawn(function()
    while gameActive do
        moveSnake()
        wait(0.2)
    end
end)

closeButton.MouseButton1Click:Connect(function()
    gameActive = false
    screenGui:Destroy()
end)

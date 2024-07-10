local ROWS = 20
local COLS = 10
local CELL_SIZE = 25
local GRID_COLOR = Color3.new(0.2, 0.2, 0.2)
local MOVE_INTERVAL = 0.5
local FAST_MOVE_INTERVAL = 0.1

local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, COLS * CELL_SIZE, 0, ROWS * CELL_SIZE)
frame.Position = UDim2.new(0.5, -COLS * CELL_SIZE / 2, 0.5, -ROWS * CELL_SIZE / 2 + 25)
frame.BackgroundColor3 = Color3.new(1, 1, 1)
frame.Parent = screenGui

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 50, 0, 50)
closeButton.Position = UDim2.new(1, -50, 0, 0)
closeButton.Text = "X"
closeButton.BackgroundColor3 = Color3.new(1, 0, 0)
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Parent = frame
closeButton.ZIndex = 2

local grid = {}
local activePiece
local gameRunning = true

for row = 1, ROWS do
    grid[row] = {}
    for col = 1, COLS do
        local cell = Instance.new("Frame")
        cell.Size = UDim2.new(0, CELL_SIZE, 0, CELL_SIZE)
        cell.Position = UDim2.new(0, (col - 1) * CELL_SIZE, 0, (row - 1) * CELL_SIZE)
        cell.BackgroundColor3 = GRID_COLOR
        cell.BorderSizePixel = 1
        cell.BorderColor3 = Color3.new(0.1, 0.1, 0.1)
        cell.Parent = frame
        grid[row][col] = cell
    end
end

local pieces = {
    { {1, 1, 1, 1} },
    { {1, 1}, {1, 1} },
    { {0, 1, 0}, {1, 1, 1} },
    { {0, 1, 1}, {1, 1, 0} },
    { {1, 1, 0}, {0, 1, 1} },
    { {1, 0, 0}, {1, 1, 1} },
    { {0, 0, 1}, {1, 1, 1} }
}

local function createPiece()
    local pieceType = pieces[math.random(#pieces)]
    local piece = {}
    local color = Color3.new(math.random(), math.random(), math.random())
    for i = 1, #pieceType do
        piece[i] = {}
        for j = 1, #pieceType[i] do
            piece[i][j] = {pieceType[i][j], color}
        end
    end
    return piece
end

local function drawPiece(piece, x, y)
    for i = 1, #piece do
        for j = 1, #piece[i] do
            if piece[i][j][1] == 1 and grid[y + i] and grid[y + i][x + j] then
                grid[y + i][x + j].BackgroundColor3 = piece[i][j][2]
            end
        end
    end
end

local function clearPiece(piece, x, y)
    for i = 1, #piece do
        for j = 1, #piece[i] do
            if piece[i][j][1] == 1 and grid[y + i] and grid[y + i][x + j] then
                grid[y + i][x + j].BackgroundColor3 = GRID_COLOR
            end
        end
    end
end

local function rotatePiece(piece)
    local rotatedPiece = {}
    local n = #piece
    for i = 1, n do
        rotatedPiece[i] = {}
        for j = 1, #piece[i] do
            rotatedPiece[i][j] = {piece[n - j + 1][i][1], piece[n - j + 1][i][2]}
        end
    end
    return rotatedPiece
end

local function checkCollision(piece, x, y)
    for i = 1, #piece do
        for j = 1, #piece[i] do
            if piece[i][j][1] == 1 then
                if not grid[y + i] or not grid[y + i][x + j] or grid[y + i][x + j].BackgroundColor3 ~= GRID_COLOR then
                    return true
                end
            end
        end
    end
    return false
end

local function lockPiece(piece, x, y)
    for i = 1, #piece do
        for j = 1, #piece[i] do
            if piece[i][j][1] == 1 and grid[y + i] and grid[y + i][x + j] then
                grid[y + i][x + j].BackgroundColor3 = piece[i][j][2]
            end
        end
    end
    activePiece = nil
end

local function deleteFullRows()
    for row = ROWS, 1, -1 do
        local full = true
        for col = 1, COLS do
            if grid[row][col].BackgroundColor3 == GRID_COLOR then
                full = false
                break
            end
        end
        if full then
            for r = row, 2, -1 do
                for c = 1, COLS do
                    grid[r][c].BackgroundColor3 = grid[r - 1][c].BackgroundColor3
                end
            end
            for c = 1, COLS do
                grid[1][c].BackgroundColor3 = GRID_COLOR
            end
            row = row + 1
        end
    end
end

local function onInput(input)
    if not gameRunning then return end
    if not activePiece then return end
    local key = input.KeyCode
    clearPiece(activePiece.piece, activePiece.x, activePiece.y)
    local newX, newY = activePiece.x, activePiece.y
    local newPiece = activePiece.piece
    if key == Enum.KeyCode.A then
        newX = newX - 1
        if newX < 1 then
            newX = 1
        end
    elseif key == Enum.KeyCode.D then
        newX = newX + 1
        if newX + #activePiece.piece[1] - 1 > COLS then
            newX = COLS - #activePiece.piece[1] + 1
        end
    elseif key == Enum.KeyCode.S then
        newY = newY + 1
        movePieceDown()
    elseif key == Enum.KeyCode.Space then
        local rotatedPiece = rotatePiece(activePiece.piece)
        if not checkCollision(rotatedPiece, newX, newY) then
            activePiece.piece = rotatedPiece
        end
    end
    drawPiece(activePiece.piece, newX, newY)
    activePiece.x, activePiece.y = newX, newY
end

local function movePieceDown()
    if not gameRunning then return end
    if activePiece then
        clearPiece(activePiece.piece, activePiece.x, activePiece.y)
        local newY = activePiece.y + 1
        if checkCollision(activePiece.piece, activePiece.x, newY) then
            lockPiece(activePiece.piece, activePiece.x, activePiece.y)
            deleteFullRows()
            activePiece = { piece = createPiece(), x = 4, y = 1 }
            if checkCollision(activePiece.piece, activePiece.x, activePiece.y) then
                gameRunning = false
                print("Game Over")
            else
                drawPiece(activePiece.piece, activePiece.x, activePiece.y)
            end
        else
            activePiece.y = newY
        end
        drawPiece(activePiece.piece, activePiece.x, activePiece.y)
    else
        activePiece = { piece = createPiece(), x = 4, y = 1 }
        if checkCollision(activePiece.piece, activePiece.x, activePiece.y) then
            gameRunning = false
            print("Game Over")
        else
            drawPiece(activePiece.piece, activePiece.x, activePiece.y)
        end
    end
end

local function onContinuousS()
    while gameRunning do
        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.S) then
            movePieceDown()
            wait(FAST_MOVE_INTERVAL)
        else
            wait()
        end
    end
end

local function closeGame()
    gameRunning = false
    screenGui:Destroy()
end

closeButton.MouseButton1Click:Connect(closeGame)
game:GetService("UserInputService").InputBegan:Connect(onInput)

coroutine.wrap(onContinuousS)()

while gameRunning do
    movePieceDown()
    wait(MOVE_INTERVAL)
end

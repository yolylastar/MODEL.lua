--[[
	Shop UI Module for Dive & Dash
	Allows players to sell their collected items
]]

local ShopUI = {}
ShopUI.__index = ShopUI

-- Services
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Remote Events
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local SellItemEvent = RemoteEvents:WaitForChild("SellItem")
local SellAllEvent = RemoteEvents:WaitForChild("SellAll")

-- Configuration
local ITEM_HEIGHT = 60

function ShopUI.new(screenGui: ScreenGui)
	local self = setmetatable({}, ShopUI)
	
	self.screenGui = screenGui
	self.playerMoney = 0
	
	self:createUI()
	self:setupConnections()
	
	return self
end

function ShopUI:createUI()
	-- Main Frame
	self.mainFrame = Instance.new("Frame")
	self.mainFrame.Name = "ShopFrame"
	self.mainFrame.Size = UDim2.new(0, 550, 0, 650)
	self.mainFrame.Position = UDim2.new(0.5, -275, 0.5, -325)
	self.mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	self.mainFrame.BorderSizePixel = 0
	self.mainFrame.Visible = false
	self.mainFrame.Parent = self.screenGui
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = self.mainFrame
	
	-- Header
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 60)
	header.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
	header.BorderSizePixel = 0
	header.Parent = self.mainFrame
	
	local headerCorner = Instance.new("UICorner")
	headerCorner.CornerRadius = UDim.new(0, 12)
	headerCorner.Parent = header
	
	local headerBottomCover = Instance.new("Frame")
	headerBottomCover.Size = UDim2.new(1, 0, 0, 12)
	headerBottomCover.Position = UDim2.new(0, 0, 1, -12)
	headerBottomCover.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
	headerBottomCover.BorderSizePixel = 0
	headerBottomCover.Parent = header
	
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, -100, 1, 0)
	title.Position = UDim2.new(0, 20, 0, 0)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.Text = "🏪 Shop - Sell Items"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextSize = 24
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = header
	
	-- Close Button
	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0, 40, 0, 40)
	closeButton.Position = UDim2.new(1, -50, 0.5, -20)
	closeButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
	closeButton.BorderSizePixel = 0
	closeButton.Font = Enum.Font.GothamBold
	closeButton.Text = "✕"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.TextSize = 20
	closeButton.Parent = header
	
	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 8)
	closeCorner.Parent = closeButton
	
	closeButton.Activated:Connect(function()
		self:hide()
	end)
	
	-- Money Display
	local moneyFrame = Instance.new("Frame")
	moneyFrame.Name = "MoneyFrame"
	moneyFrame.Size = UDim2.new(1, -40, 0, 50)
	moneyFrame.Position = UDim2.new(0, 20, 0, 80)
	moneyFrame.BackgroundColor3 = Color3.fromRGB(241, 196, 15)
	moneyFrame.BorderSizePixel = 0
	moneyFrame.Parent = self.mainFrame
	
	local moneyCorner = Instance.new("UICorner")
	moneyCorner.CornerRadius = UDim.new(0, 8)
	moneyCorner.Parent = moneyFrame
	
	self.moneyLabel = Instance.new("TextLabel")
	self.moneyLabel.Name = "MoneyLabel"
	self.moneyLabel.Size = UDim2.new(1, -20, 1, 0)
	self.moneyLabel.Position = UDim2.new(0, 10, 0, 0)
	self.moneyLabel.BackgroundTransparency = 1
	self.moneyLabel.Font = Enum.Font.GothamBold
	self.moneyLabel.Text = "💰 Your Money: $0"
	self.moneyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	self.moneyLabel.TextSize = 20
	self.moneyLabel.TextXAlignment = Enum.TextXAlignment.Left
	self.moneyLabel.Parent = moneyFrame
	
	-- Items List
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Name = "ItemsList"
	scrollFrame.Size = UDim2.new(1, -40, 1, -250)
	scrollFrame.Position = UDim2.new(0, 20, 0, 150)
	scrollFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	scrollFrame.BorderSizePixel = 0
	scrollFrame.ScrollBarThickness = 8
	scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(46, 204, 113)
	scrollFrame.Parent = self.mainFrame
	
	local scrollCorner = Instance.new("UICorner")
	scrollCorner.CornerRadius = UDim.new(0, 8)
	scrollCorner.Parent = scrollFrame
	
	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 8)
	listLayout.Parent = scrollFrame
	
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 10)
	padding.PaddingBottom = UDim.new(0, 10)
	padding.PaddingLeft = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 10)
	padding.Parent = scrollFrame
	
	-- Sell All Button
	local sellAllButton = Instance.new("TextButton")
	sellAllButton.Name = "SellAllButton"
	sellAllButton.Size = UDim2.new(1, -40, 0, 60)
	sellAllButton.Position = UDim2.new(0, 20, 1, -80)
	sellAllButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
	sellAllButton.BorderSizePixel = 0
	sellAllButton.Font = Enum.Font.GothamBold
	sellAllButton.Text = "💵 SELL ALL ITEMS"
	sellAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	sellAllButton.TextSize = 20
	sellAllButton.Parent = self.mainFrame
	
	local sellAllCorner = Instance.new("UICorner")
	sellAllCorner.CornerRadius = UDim.new(0, 8)
	sellAllCorner.Parent = sellAllButton
	
	sellAllButton.Activated:Connect(function()
		self:sellAllItems()
	end)
	
	-- Hover effect for sell all button
	sellAllButton.MouseEnter:Connect(function()
		TweenService:Create(sellAllButton, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(39, 174, 96)
		}):Play()
	end)
	
	sellAllButton.MouseLeave:Connect(function()
		TweenService:Create(sellAllButton, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(46, 204, 113)
		}):Play()
	end)
end

function ShopUI:setupConnections()
	-- Update money when it changes
	local player = Players.LocalPlayer
	local leaderstats = player:WaitForChild("leaderstats", 5)
	
	if leaderstats then
		local money = leaderstats:WaitForChild("Money", 5)
		if money then
			self.playerMoney = money.Value
			self:updateMoneyDisplay()
			
			money:GetPropertyChangedSignal("Value"):Connect(function()
				self.playerMoney = money.Value
				self:updateMoneyDisplay()
			end)
		end
	end
end

function ShopUI:updateMoneyDisplay()
	self.moneyLabel.Text = string.format("💰 Your Money: $%d", self.playerMoney)
end

function ShopUI:populateItems(inventoryData: {[string]: number})
	local itemsList = self.mainFrame.ItemsList
	
	-- Clear existing items
	for _, child in pairs(itemsList:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	
	local totalValue = 0
	
	-- Create item entries
	for itemName, quantity in pairs(inventoryData) do
		if quantity > 0 then
			local itemData = self:getItemData(itemName)
			local itemValue = itemData.value * quantity
			totalValue = totalValue + itemValue
			
			self:createItemEntry(itemName, quantity, itemData, itemsList)
		end
	end
	
	-- Update canvas size
	itemsList.CanvasSize = UDim2.new(0, 0, 0, itemsList.UIListLayout.AbsoluteContentSize.Y + 20)
end

function ShopUI:createItemEntry(itemName: string, quantity: number, itemData: {}, parent: ScrollingFrame)
	local entry = Instance.new("Frame")
	entry.Name = itemName .. "Entry"
	entry.Size = UDim2.new(1, -20, 0, ITEM_HEIGHT)
	entry.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	entry.BorderSizePixel = 0
	entry.Parent = parent
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = entry
	
	-- Item Icon
	local icon = Instance.new("TextLabel")
	icon.Name = "Icon"
	icon.Size = UDim2.new(0, 50, 0, 50)
	icon.Position = UDim2.new(0, 5, 0.5, -25)
	icon.BackgroundTransparency = 1
	icon.Font = Enum.Font.GothamBold
	icon.Text = itemData.icon or "📦"
	icon.TextSize = 32
	icon.Parent = entry
	
	-- Item Info
	local infoFrame = Instance.new("Frame")
	infoFrame.Size = UDim2.new(1, -230, 1, 0)
	infoFrame.Position = UDim2.new(0, 60, 0, 0)
	infoFrame.BackgroundTransparency = 1
	infoFrame.Parent = entry
	
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "ItemName"
	nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.Text = itemName
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextSize = 16
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = infoFrame
	
	local quantityLabel = Instance.new("TextLabel")
	quantityLabel.Name = "Quantity"
	quantityLabel.Size = UDim2.new(1, 0, 0.5, 0)
	quantityLabel.Position = UDim2.new(0, 0, 0.5, 0)
	quantityLabel.BackgroundTransparency = 1
	quantityLabel.Font = Enum.Font.Gotham
	quantityLabel.Text = string.format("Quantity: %d | Unit Price: $%d", quantity, itemData.value)
	quantityLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	quantityLabel.TextSize = 14
	quantityLabel.TextXAlignment = Enum.TextXAlignment.Left
	quantityLabel.Parent = infoFrame
	
	-- Value Display
	local valueLabel = Instance.new("TextLabel")
	valueLabel.Name = "Value"
	valueLabel.Size = UDim2.new(0, 80, 1, 0)
	valueLabel.Position = UDim2.new(1, -170, 0, 0)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Font = Enum.Font.GothamBold
	valueLabel.Text = string.format("$%d", itemData.value * quantity)
	valueLabel.TextColor3 = Color3.fromRGB(46, 204, 113)
	valueLabel.TextSize = 18
	valueLabel.Parent = entry
	
	-- Sell Button
	local sellButton = Instance.new("TextButton")
	sellButton.Name = "SellButton"
	sellButton.Size = UDim2.new(0, 70, 0, 40)
	sellButton.Position = UDim2.new(1, -80, 0.5, -20)
	sellButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
	sellButton.BorderSizePixel = 0
	sellButton.Font = Enum.Font.GothamBold
	sellButton.Text = "SELL"
	sellButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	sellButton.TextSize = 14
	sellButton.Parent = entry
	
	local sellCorner = Instance.new("UICorner")
	sellCorner.CornerRadius = UDim.new(0, 6)
	sellCorner.Parent = sellButton
	
	sellButton.Activated:Connect(function()
		self:sellItem(itemName, quantity)
	end)
	
	-- Hover effects
	sellButton.MouseEnter:Connect(function()
		TweenService:Create(sellButton, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(39, 174, 96)
		}):Play()
	end)
	
	sellButton.MouseLeave:Connect(function()
		TweenService:Create(sellButton, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(46, 204, 113)
		}):Play()
	end)
end

function ShopUI:getItemData(itemName: string): {}
	-- Same database as InventoryUI
	local itemDatabase = {
		["Rusty Can"] = { icon = "🥫", value = 5 },
		["Old Bottle"] = { icon = "🍾", value = 8 },
		["Broken Phone"] = { icon = "📱", value = 25 },
		["Gold Ring"] = { icon = "💍", value = 100 },
		["Diamond"] = { icon = "💎", value = 500 },
		["Old Shoe"] = { icon = "👟", value = 3 },
		["Wallet"] = { icon = "👛", value = 50 },
		["Watch"] = { icon = "⌚", value = 150 },
	}
	
	return itemDatabase[itemName] or { icon = "❓", value = 0 }
end

function ShopUI:sellItem(itemName: string, quantity: number)
	-- Send sell request to server
	SellItemEvent:FireServer(itemName, quantity)
	
	-- Show feedback
	self:showSellFeedback(itemName, quantity)
end

function ShopUI:sellAllItems()
	-- Send sell all request to server
	SellAllEvent:FireServer()
	
	-- Show feedback
	self:showSellFeedback("All Items", 0, true)
end

function ShopUI:showSellFeedback(itemName: string, quantity: number, isAll: boolean)
	local feedbackLabel = Instance.new("TextLabel")
	feedbackLabel.Size = UDim2.new(0, 300, 0, 50)
	feedbackLabel.Position = UDim2.new(0.5, -150, 0.5, -25)
	feedbackLabel.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
	feedbackLabel.BorderSizePixel = 0
	feedbackLabel.Font = Enum.Font.GothamBold
	feedbackLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	feedbackLabel.TextSize = 18
	feedbackLabel.Text = isAll and "✓ Sold All Items!" or string.format("✓ Sold %s x%d", itemName, quantity)
	feedbackLabel.Parent = self.screenGui
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = feedbackLabel
	
	-- Animate in
	feedbackLabel.BackgroundTransparency = 1
	feedbackLabel.TextTransparency = 1
	
	local tweenIn = TweenService:Create(feedbackLabel, TweenInfo.new(0.3), {
		BackgroundTransparency = 0,
		TextTransparency = 0
	})
	
	tweenIn:Play()
	
	-- Animate out after delay
	task.wait(2)
	
	local tweenOut = TweenService:Create(feedbackLabel, TweenInfo.new(0.3), {
		BackgroundTransparency = 1,
		TextTransparency = 1,
		Position = UDim2.new(0.5, -150, 0.3, -25)
	})
	
	tweenOut.Completed:Connect(function()
		feedbackLabel:Destroy()
	end)
	
	tweenOut:Play()
end

function ShopUI:show()
	self.mainFrame.Visible = true
	self.mainFrame.Position = UDim2.new(0.5, -275, 1, 0)
	
	-- Get current inventory from server
	local player = Players.LocalPlayer
	local inventory = player:FindFirstChild("Inventory")
	if inventory then
		local inventoryData = {}
		for _, item in pairs(inventory:GetChildren()) do
			if item:IsA("IntValue") then
				inventoryData[item.Name] = item.Value
			end
		end
		self:populateItems(inventoryData)
	end
	
	TweenService:Create(self.mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
		Position = UDim2.new(0.5, -275, 0.5, -325)
	}):Play()
end

function ShopUI:hide()
	local tween = TweenService:Create(self.mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
		Position = UDim2.new(0.5, -275, 1, 0)
	})
	
	tween.Completed:Connect(function()
		self.mainFrame.Visible = false
	end)
	
	tween:Play()
end

function ShopUI:isVisible(): boolean
	return self.mainFrame.Visible
end

return ShopUI

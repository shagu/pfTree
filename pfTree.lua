pfUI:RegisterModule("treebrowser", function ()
  local size = 24

  local function OnShow()
    if not this.data then return end

    local data = this.data
    local draw = this.draw

    this.caption:SetText(data[1])

    if type(data[2]) == "table" then
      if data[2].GetObjectType and type(data[2].GetObjectType) == "function" and data[2]:GetObjectType() == "FontString" then
        this.tex:SetTexture("Interface\\AddOns\\pfTree\\img\\FontString")
      elseif data[2].GetObjectType and type(data[2].GetObjectType) == "function" and data[2]:GetObjectType() == "Texture" then
        this.tex:SetTexture("Interface\\AddOns\\pfTree\\img\\Texture")
      elseif data[2].GetObjectType and type(data[2].GetObjectType) == "function" then
        this.tex:SetTexture("Interface\\AddOns\\pfTree\\img\\Frame")
      else
        this.tex:SetTexture("Interface\\AddOns\\pfTree\\img\\table")
      end
    elseif type(data[2]) == "function" then
      this.tex:SetTexture("Interface\\AddOns\\pfTree\\img\\function")
    elseif type(data[2]) == "string" then
      this.tex:SetTexture("Interface\\AddOns\\pfTree\\img\\string")
    else
      this.tex:SetTexture("Interface\\AddOns\\pfTree\\img\\number")
    end

    this:SetParent(this.draw)
    this:SetPoint("TOPLEFT", this.draw, "TOPLEFT", 10, -(this.id-1)*30 - 10)
    this:SetWidth(this.draw:GetWidth())
    this.caption:SetWidth(this.draw:GetWidth() - 50)
  end

  local function OnClick()
    if this.draw and this.draw.Open then
      message("Open: " .. this.data[1])
      if type(this.data[2]) == "table" then
        this.draw.Open(this.draw.path[this.data[1]], this.draw)
      end
    end
  end

  local function CreateIcon(typ, name)
    local f = CreateFrame("Button")
    f:Hide()

    f:SetScript("OnShow", OnShow)

    f:SetScript("OnClick", OnClick)
    f:SetHeight(size)
    f:SetWidth(size)

    f.tex = f:CreateTexture(nil, "Overlay")
    f.tex:SetPoint("LEFT", 0, 0)
    f.tex:SetWidth(size)
    f.tex:SetHeight(size)
    f.tex:SetTexture("Interface\\AddOns\\pfTree\\img\\number")

    f.caption = f:CreateFontString("Status", "LOW", "GameFontNormal")
    f.caption:SetPoint("TOPLEFT", f.tex, "TOPRIGHT", 10, 0)
    f.caption:SetPoint("BOTTOMLEFT", f.tex, "BOTTOMRIGHT", 10, 0)
    f.caption:SetJustifyH("LEFT")

    f.SetData = SetData
    f.SetPosition = SetPosition
    return f
  end

  local function PrepareView(path)
    local tmp = { }

    for name, obj in pairs(path) do
      table.insert(tmp, { name, obj })
    end

    return tmp
  end

  local function Open(path, draw)
    local scrollparent = draw:GetParent()
    scrollparent:Hide()

    draw.view = draw.view or {}
    for id, frame in pairs(draw.view) do
      frame.data = nil
      frame:Hide()
    end

    local id = 0
    local display = PrepareView(path)
    for name, data in pairs(display) do
      id = id + 1
      draw.view[id] = draw.view[id] or CreateIcon()
      draw.view[id].id = id
      draw.view[id].data = data
      draw.view[id].draw = draw
    end

    draw:SetHeight(table.getn(display)*30+10)
    draw.path = path
    draw.Open = Open

    scrollparent:SetVerticalScroll(0)
    scrollparent:Show()
  end

  local browser = CreateScrollFrame("GTreeBrowser", UIParent)
  browser:Hide()
  browser:SetWidth(500)
  browser:SetHeight(500)
  browser:SetPoint("CENTER", 0, 0)

  -- _G is way to big to build all items at once
  local function BrowserUpdateWindow()
    local list = this:GetScrollChild()
    local height = this:GetHeight()
    local size = 30
    local top_index, bottom_index, range
    range = floor(height / size)
    top_index = floor(height / size) > 0 and floor(height / size) or 1
    top_index = floor(this:GetVerticalScroll() / size) > 0 and floor(this:GetVerticalScroll() / size) or 1
    bottom_index = top_index + range + size

    for i=1, table.getn(list.view) do
      if list.view[i].data and i >= top_index and i <= bottom_index then
        list.view[i]:Show()
      else
        list.view[i]:Hide()
      end
    end
  end

  browser:SetScript("OnVerticalScroll", BrowserUpdateWindow)
  browser:SetScript("OnShow", BrowserUpdateWindow)

  CreateBackdrop(browser)
  UpdateMovable(browser)

  local list = CreateScrollChild("GTreeList", browser)
  list:SetWidth(browser:GetWidth())

  local time = GetTime()
  Open(_G, list)
  message("Took " .. GetTime() - time)
end, true)
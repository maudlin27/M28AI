--Copied from FAF simsyncutils.lua
--copyright assumed to be that of wider FAF project - copy from other FAF file copied below, which is assumed to apply to the below

--******************************************************************************************************
--**
--** Permission is hereby granted, free of charge, to any person obtaining a copy
--** of this software and associated documentation files (the "Software"), to deal
--** in the Software without restriction, including without limitation the rights
--** to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--** copies of the Software, and to permit persons to whom the Software is
--** furnished to do so, subject to the following conditions:
--**
--** The above copyright notice and this permission notice shall be included in all
--** copies or substantial portions of the Software.
--**
--** THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--** IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--** FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--** AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--** LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--** OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--** SOFTWARE.
--******************************************************************************************************


---@param data SimCameraEvent
function SyncCameraRequest(data)
    local Sync = Sync
    Sync.CameraRequests = Sync.CameraRequests or { }
    table.insert(Sync.CameraRequests, data)
end

---@param data SoundBlueprint
function SyncVoice(data)
    local Sync = Sync
    Sync.Voice = Sync.Voice or { }
    table.insert(Sync.Voice, data)
end

function SyncAIChat(data)
    local Sync = Sync
    Sync.AIChat = Sync.AIChat or { }
    table.insert(Sync.AIChat, data)
end

function SyncGameResult(data)
    local Sync = Sync
    Sync.GameResult = Sync.GameResult or { }
    table.insert(Sync.GameResult, data)
end

function SyncPlayerQuery(data)
    local Sync = Sync
    Sync.PlayerQueries = Sync.PlayerQueries or { }
    table.insert(Sync.PlayerQueries, data)
end

function SyncQueryResult(data)
    local Sync = Sync
    Sync.QueryResults = Sync.QueryResults or { }
    table.insert(Sync.QueryResults, data)
end
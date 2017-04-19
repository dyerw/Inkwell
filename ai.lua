require("wordlookup")

function take(table, n)
    result = {}
    for i=0, n do
        result[#result + 1] = table[i]
    end
    return result
end

function concat(t1,t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end

local function getAdjacentTiles(x, y, board)
  local result = {}
  for newX=(x - 1),(x + 1) do
    for newY=(y - 1),(y + 1) do
        local sameTile = newX == x and newY == y
        local inBounds = (newX >= 1 and newX <= #board) and (newY >= 1 and newY <= #(board[1]))
        if not sameTile and inBounds then
          result[#result + 1] = {x=newX, y=newY}
        end
    end
  end

  return result
end

function inBoard(word, board, x, y)
    if word == "" then
        return true
    end

    if string.lower(board[x][y]) == string.sub(word, 1, 1) then
      local adjacentTiles = getAdjacentTiles(x, y, board)
      for i=1, #adjacentTiles do
          local tile = adjacentTiles[i]
          if inBoard(string.sub(word, 2), board, tile['x'], tile['y']) then
            return true
          end
      end
    end

    return false
end

local function allWords(board, words)
    local result = {}
    for x=1, #board do
      for y=1, #(board[1]) do
        for i=1,#words do
            if inBoard(words[i], board, x, y) then
              result[#result + 1] = words[i]
            end
        end
      end
    end
    local longest = 0
    local longestWord = nil
    for k, v in pairs(result) do
        if string.len(v) > longest then
          longest = string.len(v)
          longestWord = v
        end
    end

    print(longestWord)
    return longestWord
end

function makeMove(board, words)
    -- words = take(words, 1000)
    return allWords(board, words)
end

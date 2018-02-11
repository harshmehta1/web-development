defmodule Memory.Game do
  @moduledoc """
  This includes the logic of the Memory Game
  """

  @doc """
    This function creates a new state for the game
  """
  def new do
    %{
      tiles: newTiles(),
      guessedTiles: [],
      tilesMatched: 0,
      selectedTiles: MapSet.new,
      score: 0,
      clicks: 0,
      paused: false
    }
  end


  @doc """
    This functions sets the view at the client side
  """
  def client_view(game) do
    tls = game.tiles
    guessedTls = game.guessedTiles
    pauseState = game.paused
    tm = game.tilesMatched
    sc = game.score
    sltCount = MapSet.size(game.selectedTiles)
    %{
      skel: skeleton(tls, guessedTls),
      tilesMatched: tm,
      score: sc,
      paused: pauseState,
      tilesSelected: sltCount,
    }
  end

  @doc """
    This function hides all the times that are not matched or temporarily
    guessed by the player
  """
  def skeleton(tiles, guessedTiles) do
    tiles = tiles
    Enum.map tiles, fn tl ->
      if Map.get(tl, :flipped) == true or Enum.member?(guessedTiles, tl) do
        tl
      else
        Map.replace!(tl,:val,"?")
      end
    end
  end


  @doc """
    This function is called when user clicks on a Tile.
    If the game is not paused, it changes flipped value of tile to true
    and if 2 tiles have been selected it pauses the game temporarily
  """
  def clickTile(game, id) do
    tls = game.tiles
    selectTl = game.selectedTiles
    paused = game.paused
    cond do
      paused == true or
      MapSet.size(selectTl) >= 3 or
      isSelected(selectTl, id)->
        game
      MapSet.size(selectTl) < 3 ->
        tls = Enum.map tls, fn tl ->
                if Map.get(tl, :id) == id do
                  %{tl | flipped: true}
                else
                  tl
                end
              end
        tilesSelected = Enum.filter(tls, fn(t) ->
          Map.get(t, :id) == id end)
        selectTl = MapSet.put(selectTl, tilesSelected)
        if MapSet.size(selectTl) == 2 do
            Map.put(game, :tiles, tls)
                  |> Map.put(:selectedTiles, selectTl)
                  |> Map.put(:paused, true)
        else
            Map.put(game, :tiles, tls)
                  |> Map.put(:selectedTiles, selectTl)
        end
    end
  end


  @doc """
    This functions checks if the tile clicked has been selected already
  """
  def isSelected(selectTl, id) do
    Enum.any? selectTl, fn t ->
              Map.get(hd(t), :id) == id
            end
  end

  @doc """
    This function checks if the two selected Tiles match.
    If they match, marks them as matched and if not, flips the tiles back.
  """
  def checkMatch(game) do
    add_score = 20
    slt = game.selectedTiles
    tls = game.tiles
    sc = game.score
    tm = game.tilesMatched
    if MapSet.size(slt) > 1 do
      sltVals = Enum.map slt, fn t ->
                  Map.get(hd(t), :val) end
      tls = game.tiles

      if List.first(sltVals) == List.last(sltVals) do
          tls = Enum.map tls, fn tl ->
            if Map.get(tl, :val) == List.first(sltVals) do
              %{tl | matched: true}
            else
              tl
            end
          end
          :timer.sleep(500)
          sc = sc + add_score
          tm = tm + 2
          Map.put(game, :tiles, tls)
                  |> Map.put(:selectedTiles, MapSet.new)
                  |> Map.put(:paused, false)
                  |> Map.put(:score, sc)
                  |> Map.put(:tilesMatched, tm)
      else
          :timer.sleep(1000)
          flipBack(game)
      end
    end
  end

  @doc """
    This function changes the flipped flag of 2 selected tiles to false and
    unpauses the temporarily paused game.
  """
  def flipBack(game) do
    sub_score = 5
    sc = game.score
    tls = game.tiles
    tls = Enum.map tls, fn tl ->
      if Map.get(tl, :matched) == false do
        %{tl | flipped: false}
      else
        tl
      end
    end
    sc = sc - sub_score
    Map.put(game, :tiles, tls)
     |> Map.put(:selectedTiles, MapSet.new)
     |> Map.put(:paused, false)
     |> Map.put(:score, sc)
  end

  @doc """
    This function resets the game and generates a whole new state for the game
  """
  def reset() do
    new()
  end

  @doc """
    This function passes a new shuffled list of tiles to be set as state
    of the game
  """
  def newTiles() do
    arr = getShuffledList()
    createTileList(arr, [], 0)
  end

  @doc """
    This function shuffles the alphabets
  """
  def getShuffledList() do
    alphabets = ["A","A","B","B","C","C","D","D","E","E","F","F","G","G","H","H"]
    Enum.shuffle(alphabets)
  end

  @doc """
    This function creates the list of tiles from the given list of alphabets
  """
  def createTileList([], newtiles, counter) do
    newtiles
  end

  @doc """
      This function creates the list of tiles from the given list of alphabets
  """
  def createTileList([head | tail], newtiles, counter) do
    newtiles = newtiles ++ [%{:val => head, :flipped => false, :matched => false, :id => counter}]
    counter = counter + 1
    createTileList(tail, newtiles, counter)
  end
end

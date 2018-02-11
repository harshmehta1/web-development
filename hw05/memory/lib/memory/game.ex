defmodule Memory.Game do


  def new do
    %{
      tiles: createTileList(getShuffledList(), [], 0),
      guessedTiles: [],
      tilesMatched: 0,
      selectedTiles: MapSet.new,
      score: 0,
      clicks: 0,
      paused: false
    }
  end



  def client_view(game) do
    tls = game.tiles
    guessedTls = game.guessedTiles
    pauseState = game.paused
    tm = game.tilesMatched
    sc = game.score
    %{
      skel: skeleton(tls, guessedTls),
      tilesMatched: tm,
      score: sc,
      paused: pauseState,
    }
  end

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



def clickTile(game, id) do
  tls = game.tiles
  selectTl = game.selectedTiles
  paused = game.paused
  # cond do
  #   MapSet.size(selectTl) < 2 ->
  #     #do something
  #
  # end
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
        game = Map.put(game, :tiles, tls)
                |> Map.put(:selectedTiles, selectTl)
                |> Map.put(:paused, true)
        # flipBack(game)

        # tick = spawn(Memory.Game, :handleTick, [game])
        # send(tick, :flip)
        # Process.send_after(self(), :flip, 1000)
      else
        game = Map.put(game, :tiles, tls)
                |> Map.put(:selectedTiles, selectTl)
      end
    end
  game
end



def isSelected(selectTl, id) do
  Enum.any? selectTl, fn t ->
            Map.get(hd(t), :id) == id
          end
end
#
# def handleTick(game) do
#   receive do
#     :flip ->
#       tls = game.tiles
#       tls = Enum.map tls, fn tl ->
#         if Map.get(tl, :matched) == false do
#           %{tl | flipped: false}
#         else
#           tl
#         end
#       end
#       Map.put(game, :tiles, tls)
#        |> Map.put(:selectedTiles, MapSet.new)
#        |> Map.put(:paused, false)
#   end
# end

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
        # IO.inspect("IN LOOP")
        # IO.inspect(List.first(sltVals))
        # IO.inspect(List.last(sltVals))
        tls = Enum.map tls, fn tl ->
          if Map.get(tl, :val) == List.first(sltVals) do
            %{tl | matched: true}
          else
            tl
          end
        end
        :timer.sleep(501)
        sc = sc + add_score
        tm = tm + 2
        game = Map.put(game, :tiles, tls)
        |> Map.put(:selectedTiles, MapSet.new)
        |> Map.put(:paused, false)
        |> Map.put(:score, sc)
        |> Map.put(:tilesMatched, tm)
      else
        :timer.sleep(1000)
        game = flipBack(game)
      end

    end

    game
  end

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

  def reset() do
    new
  end

  def newTiles() do
    # rand
    # temp

    # shuffles the list
    # for (var i=alphabets.length-1; i>=0; i--){
    #   rand = Math.floor(Math.random() * alphabets.length);
    #   temp = alphabets[rand];
    #   alphabets[rand] = alphabets[i];
    #   alphabets[i] = temp;
    # }

    arr = getShuffledList()
    createTileList(arr, [], 0)
    # //adds Tiles to a new array
    # for (var j = 0; j<alphabets.length; j++){
    #   let newtile = { val: alphabets[j], flipped: false, matched: false, id: j};
    #   newtiles.push(newtile);
    # }

  end

  def getShuffledList() do
    alphabets = ["A","A","B","B","C","C","D","D","E","E","F","F","G","G","H","H"]
    Enum.shuffle(alphabets)
  end

  def createTileList([], newTiles, counter) do
    newTiles
  end

  def createTileList([head | tail], newtiles, counter) do
    newtiles = newtiles ++ [%{:val => head, :flipped => false, :matched => false, :id => counter}]
    counter = counter + 1
    createTileList(tail, newtiles, counter)
  end

  def getScore() do
    1
  end

  def getMatched() do
    0
  end


end

import React from 'react';
import ReactDOM from 'react-dom';
import { Button } from 'reactstrap';

// App state for Board is:
//   { tiles: [List of Tiles],
//    tilesMatched: Integer,
//    selectedTiles: [List of Tiles],
//    score: Integer,
//    clicks: Integer,
//    paused: Bool
//    }
//
// A Tile is:
//   { val: String,
//     flipped: Bool,
//     matched: Bool,
//     id: Integer
//   }

export default function play_game(root, channel){
  ReactDOM.render(<Board channel={channel} />, root);
}



class Board extends React.Component {
  constructor(props){
    super(props);
    this.channel = props.channel;
    this.state = {skel: [], tilesMatched: 0, score: 0, paused: false, tilesSelected: 0};

    this.channel.join()
      .receive("ok", this.gotView.bind(this))
      .receive("error", resp => {console.log("Unable to join", resp) });

  }


  gotView(view){
    this.setState(view.game);
  }

  clickTile(tile) {
    var count = this.state.tilesSelected;
    if(!tile.flipped && !tile.matched){
      if(count <= 2 && this.state.paused == false) {
        count = count + 1;
        this.channel.push("click", { id: tile.id })
          .receive("ok", this.gotView.bind(this));
          if(count == 2){
            this.channel.push("check", {})
            .receive("ok", this.gotView.bind(this));
            count = 0;
          }
        }
      }
    }

    restartGame(){
      this.channel.push("reset", {})
        .receive("ok", this.gotView.bind(this));
    }

  render() {
    //generates a list of Tiles
    let tile_list = _.map(this.state.skel, (tile, ii) => {
      return <Tile card={tile} clickTile={this.clickTile.bind(this)} key={ii} />;
    });

    //if game over, generates a pop up otherwise passes an empty div
    let game_over = <div></div>;
    let tileCount = this.state.skel.length;
    if(tileCount>0 && tileCount == this.state.tilesMatched){
      game_over = <Popup score={this.state.score} restart={this.restartGame.bind(this)} />;
    }


    return (
      <div className="game">
        {game_over}
        <div className="grid-container">
          {tile_list}
        </div>
        <div className="below">
          <div className="below-content">
            <Button id="reset" onClick={this.restartGame.bind(this)}>Restart</Button>
            <p id="score">Score: {this.state.score}</p>
        </div>
        </div>
      </div>
    )
  };

}

//this function generates a function when player wins the game
// it displays score as well as option to play again
function Popup(props){
  let score=props.score;
  return(
      <div className="popup">
        <div className="popup-content">
          <h1>You Win!</h1>
          <h3>Your score is {score}</h3>
          <Button className="play-again" onClick={() => props.restart()}>Play Again?</Button>
      </div>
    </div>
  )
}

//returns the element for tile
function Tile(props) {

  let card1 = props.card;
  var name = card1.val;
  let style;

  //decide the className and text to show depending on whether tile has been matched
  if(card1.matched){
    style = "tile-matched"
    name = "✔"
  } else {
    style = "tile"
  }
  return <Button className={style} val={card1.val} id={card1.id} onClick={() => props.clickTile(card1)}>{name}</Button>

}

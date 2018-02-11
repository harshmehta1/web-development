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



var count = 0;

class Board extends React.Component {
  constructor(props){
    super(props);
    this.channel = props.channel;
    this.state = {skel: [], tilesMatched: 0, score: 0, paused: false};

    this.channel.join()
      .receive("ok", this.gotView.bind(this))
      .receive("error", resp => {console.log("Unable to join", resp) });

  }


  gotView(view){
    console.log("New view", view);
    this.setState(view.game);
  }

  clickTile(tile) {
    if(!tile.flipped && !tile.matched){
      if(count <= 2 && this.state.paused == false) {
        count = count + 1;
        console.log(count)
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
    // return (
    //   <div className="game">
    //     <div className="grid-container">{tile_list}</div>
    //     <div className="below">
    //       <div className="below-content">
    //           <Button id="reset" onClick={this.restartGame.bind(this)}>Restart</Button>
    //           <p id="score">Score: {this.state.score}</p>
    //       </div>
    //     </div>
    //   </div>
    // )
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
  // return <Button className={style} val={card1.val} id={card1.id}>{name}</Button>

  return <Button className={style} val={card1.val} id={card1.id} onClick={() => props.clickTile(card1)}>{name}</Button>
    // return <Button>xyz</Button>

}





// //handles the click event of tile
//   clickTile(card) {
//     //if the game is not paused or card has not matched or isnt flipped
//     // do the following
//     if(!this.state.paused){
//       if(!card.matched){
//         if(!card.flipped){
//           //clone selected tiles array
//           let tilesSelected = this.state.selectedTiles.slice();
//
//           //if not more than 2 tiles are selected, do the following
//           if (tilesSelected.length<2){
//             this.flipCard(card);
//             let clickedTile = card;
//             tilesSelected.push(clickedTile);
//             let st;
//             let clicks = this.state.clicks;
//             clicks = clicks + 1;
//
//             if(tilesSelected.length==2){
//                 st = _.extend(this.state, {
//                   selectedTiles: tilesSelected,
//                   paused: true,
//                   clicks: clicks
//                 });
//                 setTimeout(() => {this.checkMatch()}, 1000);
//               } else {
//                 st = _.extend(this.state, {
//                   selectedTiles: tilesSelected,
//                   clicks: clicks
//                 });
//               }
//
//             this.setState(st);
//         }
//       }
//     }
//   }
// }

//flips the tile on click
//   flipCard(card){
//
//     let xs = _.map(this.state.tiles, (tile) =>{
//       if (tile.id == card.id) {
//         return _.extend(tile, {flipped: !card.flipped});
//       } else {
//         return tile;
//       }
//     });
//
//     let st = _.extend(this.state, {
//       tiles: xs
//     });
//
//     this.setState(st);
//
//   }
//
//   //restarts the game by initializing new set of tiles
//   restartGame(){
//     this.setState(this.newTiles());
//   }
//
// //checks if the two selected tiles have matched
//   checkMatch(){
//     //clone array
//     let selectedTiles = this.state.selectedTiles.slice();
//     let newScore = this.state.score;
//     if(selectedTiles[0].val == selectedTiles[1].val){
//       //matched - success
//       let id1 = selectedTiles[0].id;
//       let id2 = selectedTiles[1].id;
//
//       //map over the tile list and change the property of the two tiles to matched
//       let xs = _.map(this.state.tiles, (tile) => {
//         if(tile.id == id1 || tile.id == id2){
//           return _.extend(tile, {matched: true});
//         } else {
//           return tile;
//         }
//       });
//
//       //add 2 to the number of tiles matched till now
//       let matched = this.state.tilesMatched;
//       matched = matched + 2;
//
//       //increases score according to constant
//       newScore = newScore + addScore;
//
//       //updating the state
//       let st = _.extend(this.state, {
//         tiles: xs,
//         tilesMatched: matched,
//         score: newScore,
//         paused: false
//       });
//
//       this.setState(st);
//
//
//     } else {
//
//       //reduce score according to constant
//       newScore = newScore - reduceScore;
//
//       //flipping cards again as match not correct
//      for (var i=0; i<selectedTiles.length; i++){
//           this.flipCard(selectedTiles[i]);
//         }
//
//         //updating state
//         let st = _.extend(this.state, {
//           score: newScore,
//           paused: false
//         });
//
//         this.setState(st);
//
//     }
//
//     //updating the state
//     let newSelected = [];
//     let st1 = _.extend(this.state, {
//       selectedTiles: newSelected
//     })
//
//   }
//

import React, { Component } from 'react';
import contrastIconBlack from '../images/contrastIcon.png';
import contrastIconWhite from '../images/contrastIcon_white.png';
import settingsIcon from '../images/settings.png';

class IconBar extends Component {
    constructor(props) {
      super(props);
      this.state = {
        showDarkContrast: false,
        showSettingOptions: false
      };
      this.settingsIcon = <img onClick={this.handleClickSettings} className="header-icons" src={settingsIcon} />;
      this.contrastIcon = <img onClick={this.handleClickContrast} className="header-icons" src={contrastIconBlack} />;
        
      // This binding is necessary to make `this` work in the callback
      this.handleClickContrast = this.handleClickContrast.bind(this);
      this.handleClickSettings = this.handleClickSettings.bind(this);
    }
  
    handleClickContrast() {
      this.setState(state => ({
        showDarkContrast: !state.showDarkContrast
      }));
      if(this.state.showDarkContrast == false) {
        let elems = [];
        elems = document.getElementById('grid-container').childNodes;
        for (let e of elems) {
            e.style = 'background-color: black;';
        }
      } else {
        let elems = document.getElementById('grid-container').childNodes;
        for (let e of elems) {
            e.style = 'background-color: white;';
        }
      }
    }

    handleClickSettings () {
        let elem = document.getElementById('settingsModal');
        if(elem.className == "block") {
            elem.className = "none";
        } else {
            elem.className = "block";
        }

    }

    render() {
        let iconBlack = <img onClick={this.handleClickContrast} className="header-icons" src={contrastIconBlack} />;
        let iconWhite = <img onClick={this.handleClickContrast} className="header-icons" src={contrastIconWhite} />;
        this.settingsIcon = <img onClick={this.handleClickSettings} className="header-icons" src={settingsIcon} />;
        if(this.state.showDarkContrast) {
            this.contrastIcon = iconWhite;
        } else {
            this.contrastIcon = iconBlack;
        }
        return (
            <div className ="iconBar">
                {this.settingsIcon}
                {this.contrastIcon}
            </div>
        )
    }
  }

  export default IconBar;
  
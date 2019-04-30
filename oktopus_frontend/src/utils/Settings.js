import React, { Component } from 'react';
import settingsIcon from '../images/settings.png';

class Settings extends Component {
    constructor(props) {
        super(props);
        this.state = {showSettings: false};
    this.settingsIcon = <img className="header-icons" align="right" src={settingsIcon} />;
    }

    render() {
        return this.settingsIcon;
    }
}

export default Settings;
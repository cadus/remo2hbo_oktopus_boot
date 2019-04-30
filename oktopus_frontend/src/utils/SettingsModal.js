import React from 'react';
import PropTypes from 'prop-types';

class SettingsModal extends React.Component {
  constructor(props) {
    super(props);
    this.handleClose = this.handleClose.bind(this);
    
  }

  handleClose () {
    console.log("close");
    let elem = document.getElementById('settingsModal');
    elem.className = "none";
  }

  render() {
    const backdropStyle = {
      position: 'fixed',
      top: 0,
      bottom: 0,
      left: 0,
      right: 0,
      backgroundColor: 'rgba(51, 110, 123, 1)',
      padding: 50
    };

    // The modal "window"
    const modalStyle = {
      backgroundColor: 'rgba(51, 110, 123, 1)',
      borderRadius: 5,
      maxWidth: 500,
      minHeight: 300,
      margin: '0 auto',
      padding: 30
    };

    return (
      <div id="settingsModal" className="none">
      <div className="backdrop" style={{backdropStyle}}>
        <div className="modal" style={{modalStyle}}>
          <p>Set signal validation range</p>
            <button onClick={this.handleClose}>
              Close
            </button>
        </div>
      </div>
      </div>
    );
  }

}

SettingsModal.propTypes = {
  //onClose: PropTypes.func.isRequired,
  show: PropTypes.bool,
  children: PropTypes.node
};

export default SettingsModal;
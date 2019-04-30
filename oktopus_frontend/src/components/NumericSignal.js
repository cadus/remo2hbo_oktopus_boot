import React, { Component } from 'react';

class NumericSignal extends React.Component {

    render() {
      if (this.props.bioSignalType == "RR"){
        return (
        <div>
          <p className="bioSignalType"> {this.props.bioSignalType} </p>
          <p className="bioSignalValue"> {this.props.bioSignalValue} / {this.props.bioSignalValueAddOn}</p>
        </div>
        );
      } else {
        return (
        <div>
          <p className="bioSignalType"> {this.props.bioSignalType} </p>
          <p className="bioSignalValue"> {this.props.bioSignalValue} </p>
        </div>
        );
      }

    }
  }
  export default NumericSignal;
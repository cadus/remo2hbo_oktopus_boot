import React, { Component } from 'react';
import './App.css';
import NumericSignal from '../components/NumericSignal'
import GraphSignal from '../components/GraphSignal';
import ContrastSwitch from '../utils/ContrastSwitch';
import Settings from '../utils/Settings';
import IconBar from '../utils/IconBar';
import SettingsModal from '../utils/SettingsModal';



class App extends Component {

    constructor(props) {
      super(props);
      this.evtSource = new EventSource("http://141.45.146.235:8200");
      this.state = {
        connection: "not connected",
        ekg: 0,
        pulse: 0,
        temperature: "no signal",
        oxygen: "no signal",
        heartrate: "no signal",
        systole: "no signal",
        diastole: "no signal",
      };
      this.ekgData = [];
    }
  
    componentDidMount() {
      var that = this;
      
      this.evtSource.onerror = function (e) {
        console.log("error: ", e);
        that.setState(Object.assign({}, { connection: "error" }));
      };

      this.evtSource.onopen = function (e) {
        console.log("open: ", e);
        while(e.srcElement.readyState == 0) {
          console.log("connecting...");
          that.setState(Object.assign({}, { connection: "connecting..." }));
        }
        that.setState(Object.assign({}, { connection: "connected" }));
      };

      this.evtSource.close = function (e) {
        console.log("close: ",this.evtSource.readyState);
        that.setState(Object.assign({}, { connection: "not connected" }));
      };

        this.evtSource.addEventListener("ekg", function (e) {
        that.setState(Object.assign({}, { "ekg": e.data}));
        that.ekgData.push(e.data);
      }, false);

      this.evtSource.addEventListener("pulse", function (e) {
        that.setState(Object.assign({}, { "pulse": e.data}));
      }, false);

      this.evtSource.addEventListener("temperature", function (e) {
        that.setState(Object.assign({}, { "temperature": e.data}));
      }, false);

      this.evtSource.addEventListener("heartrate", function (e) {
        that.setState(Object.assign({}, { "heartrate": e.data}));
      }, false);

      this.evtSource.addEventListener("oxygen", function (e) {
        that.setState(Object.assign({}, { "oxygen": e.data}));
      }, false);

      this.evtSource.addEventListener("diastole", function (e) {
        that.setState(Object.assign({}, { "diastole": e.data}));
      }, false);

      this.evtSource.addEventListener("systole", function (e) {
        that.setState(Object.assign({}, { "systole": e.data}));
      }, false);
    }

    componentDidUpdate() {
      if(this.state.readyState == 0){
        this.setState(Object.assign({}, { connection: "connecting..." }));
      }
      if(this.state.readyState == 1){
        this.setState(Object.assign({}, { connection: "connected" }));
      }
      if(this.state.readyState == 2){
        this.setState(Object.assign({}, { connection: "closed" }));
      }
    }

    render() {

      return (
        <div className="app-container">
        <SettingsModal />
          <div id="header">
            OKTOPUS BIOSIGNAL MONITORING
          <IconBar/>
          </div>
          
          <div id="grid-container">

            <div className="biosignal-EKG">
              <GraphSignal bioSignalType="EKG" bioSignalValue={this.state.ekg} valueRangeMin={-10} valueRangeMax={600} />
            </div>
            <div className="biosignal-HR-Graph">
              <GraphSignal bioSignalType="Pulse" bioSignalValue={this.state.pulse} valueRangeMin={250} valueRangeMax={800}/>
            </div>
            <div className="biosignal-placeholder-Graph">
              <GraphSignal bioSignalType="EKG" bioSignalValue={this.state.ekg} valueRangeMin={-10} valueRangeMax={600} />
            </div>

            <div className="biosignal-Temp"> 
              <NumericSignal bioSignalType="Temp °C" bioSignalValue={this.state.temperature} /> 
            </div>
            <div className="biosignal-HR" >
              <NumericSignal bioSignalType="HR / min" bioSignalValue={this.state.heartrate} />
            </div>
            <div className="biosignal-sO2"  >
              <NumericSignal bioSignalType="spO2 %" bioSignalValue={this.state.oxygen} />
            </div>
            <div  className="biosignal-RR"> 
              <NumericSignal bioSignalType="Sys / Dia mmHG" bioSignalValue={this.state.diastole} bioSignalValueAddOn={this.state.systole} /> 
            </div>

          </div>

          <div id="footer">connection status: {this.state.connection}.</div>
        </div>
      );
    }
  }

  export default App;


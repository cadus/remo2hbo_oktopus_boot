import Dygraph from 'dygraphs';
import React, { Component } from 'react';
import { runInThisContext } from 'vm';
class GraphSignal extends Component {

    constructor(props){
        super(props);
        this.indexPointer = 0;
        this.graph = null;
        this.tempData = this.initialData();
    }

    render() {
        return <div id="dygraph-container" ref="chart"></div>;
    }

    componentDidMount() {
        //console.log("DidMount ", this.props.bioSignalValue);
        this.saveSignal();
        this.timerID = setInterval(
            () => this.drawGraph(),
            500
        );
      }

    componentDidUpdate() {
        //console.log("DidUpdate ", this.props.bioSignalValue);
        this.saveSignal();
    } 
    
    initialData() {
        let data = [];
        for (let i = 0; i < 500; i++) {
            let x = new Date();
            let y = 0;
            data.push([x,y]);
        };
        return data;
    }

    saveSignal() {
        //console.log("Save Signal, indexpointer: ", this.indexPointer, this.props.bioSignalType,": ", this.props.bioSignalValue ); 
        //console.log("saveSignal ", this.props.bioSignalType);
        let x = new Date();
        let y = Number(this.props.bioSignalValue);
            this.tempData.push([x, y]);
    }

    drawGraph() {
        if(this.graph == null) {

            this.graph = new Dygraph(
                this.refs.chart,
                this.tempData,
                {
                    fillGraph: false,
                    title: this.props.bioSignalType,
                    labels: ['Time', 'Biosignal'],
                    drawGrid: false,
                    valueRange: [
                        this.props.valueRangeMin , 
                        this.props.valueRangeMax , 
                    ],
                    axisLineColor: "white",
                    color: "blue",
                    drawPoints: false,
                    drawAxis: false,
                    legend: "never",
                });
        } else {
            let dygraphContainerOffsetWidth = document.getElementById('dygraph-container').offsetWidth
            console.log("width: ",dygraphContainerOffsetWidth);
            //display at most around 500 values depending on canvas width
            //ToDo: lost values, e.g. if last update at length 97 and next at 103 and offset =100, values 97,98,99 will be lost because array reduced to size 100
            if(this.tempData.length >= 500){
                let valuesToBeRemoved = this.tempData.length-500;
                //delete items from array to remain array.length at length of offsetWidth;
                this.tempData.splice(0,valuesToBeRemoved);
            }
            this.graph.updateOptions( { 'file' : this.tempData} );
        }
    }
}

export default GraphSignal;
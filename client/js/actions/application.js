"use strict";

import Constants   from   "../constants";
import Dispatcher  from   "../dispatcher";

export default {

  changeMainTab(payload){
    console.log(payload.text);
    Dispatcher.dispatch({ action: Constants.CHANGE_MAIN_TAB_PENDING, mainTab: payload.text });
  }

};
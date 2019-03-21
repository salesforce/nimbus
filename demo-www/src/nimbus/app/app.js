//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import {LightningElement, track} from 'lwc';

export default class App extends LightningElement {
  @track
  lastClick = "never";

  constructor() {
    super();
  }

  showTime(e) {
    DemoBridge.currentTime().then(t => this.lastClick = t);
  }
}

import React from 'react'
import { render } from 'react-dom'
import TextArea from '../text_area_editor/containers/text_area_edit'
import { Provider } from 'react-redux'
import { createStore, applyMiddleware } from 'redux'
import reducers from '../page_edit/reducers';
import thunk from 'redux-thunk';
import logger from 'redux-logger';
import {DraftJS, editorStateFromRaw, createTypeStrategy} from "megadraft";
import Link from "megadraft/lib/components/Link"
import mainAppDecorators from 'slickr_extensions/page_edit/additional_megadraft_decorators.js'

let store

// Render component with data
document.addEventListener('DOMContentLoaded', () => {
  let elements = document.getElementsByClassName('megadraft-text-editor')
  Array.prototype.forEach.call(elements, function(element, index) {
    const nextElementSibling = element.nextElementSibling
    const label = nextElementSibling.querySelector('label')
    const textArea = nextElementSibling.querySelector('textarea')

    const dataNode = element.childNodes[0]
    let data = JSON.parse(dataNode.getAttribute('data'))
    console.log(dataNode)

    if (data.input === '') {
      let randHex = function(len) {
        let maxlen = 8,
            min = Math.pow(16,Math.min(len,maxlen)-1),
            max = Math.pow(16,Math.min(len,maxlen)) - 1,
            n   = Math.floor( Math.random() * (max-min+1) ) + min,
            r   = n.toString(16);
        while ( r.length < len ) {
           r = r + randHex( len - maxlen );
        }
        return r;
      };

      data.input = {
        "entityMap": {},
        "blocks": [
          {
            "key": randHex(6),
            "text": "",
            "type": "unstyled",
            "depth": 0,
            "inlineStyleRanges": [],
            "entityRanges": [],
            "data": {}
          }
        ]
      }
    } else {
      data.input = JSON.parse(data.input)
    }
    let pageData = {}

    const decorators = [
      {
        strategy: createTypeStrategy("LINK"),
        component: Link
      }
    ]

    const mergedDecorators = decorators.concat(mainAppDecorators);

    const compositeDecorator = new DraftJS.CompositeDecorator(mergedDecorators)
    console.log(data.input)
    const initialState = {
      textAreaIndex: index,
      label: label,
      textArea: textArea,
      modalIsOpen: false,
      loadedImages: [],
      editorState: editorStateFromRaw(data.input, compositeDecorator)
    }

    const middlewares = [thunk];
    if (process.env.NODE_ENV === `development`) {
      middlewares.push(logger);
    }
    store = createStore(reducers, initialState, applyMiddleware(...middlewares))


    render(
      <Provider store={store}>
        <TextArea />
    </Provider>,
      nextElementSibling
    )

  })
})
export default store

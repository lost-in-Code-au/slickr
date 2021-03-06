import PropTypes from 'prop-types'
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import React, { Component } from 'react';
import SortableTree, { getFlatDataFromTree } from 'react-sortable-tree';
import * as TreeActions from '../actions'

const canDrop = ({ node, nextParent, prevPath, nextPath }) => {
  if(node.treeIndex == 0 || nextParent == null ||
      (nextParent.root_type == null ^ (
        nextParent.child_type == 'Page' || nextParent.child_type == 'Header'
      ))
    ) {
    return false
  } else {
    return true
  }
}
const FollowLink = (path) => {
  window.location.href = path
}
const canDrag = ({ node, path, treeIndex, lowerSiblingCounts }) => {
  if(treeIndex == 0) {
    return false
  } else {
    return true
  }
}
const updateState = (treeData, actions) => {
  actions.updateTree(treeData)
}
const moveNode = (node, treeData, nextTreeIndex, actions) => {
  const flatData = getFlatDataFromTree({
    treeData: treeData, getNodeKey: ({ node }) => node.id
  })
  const currentNode = flatData[nextTreeIndex]

  actions.saveNodePosition(
    node,
    currentNode.parentNode.id,
    currentNode.parentNode.children.map(function(x) {
      return x.id;
    }).indexOf(currentNode.node.id) + 1
  )
}

const deleteNavigation = (path, actions) => {
  actions.deleteNavigation(path)
}

const Tree = ({store, navigations, actions}) => (
  <div style={{height: "100vh"}}>
    <SortableTree
      treeData={navigations}
      onMoveNode={
        ({ node, treeData, nextTreeIndex }) =>
         moveNode(node, treeData, nextTreeIndex, actions)
      }
      maxDepth={(() => {
        if(navigations.length === 0) {
          0
        } else if(navigations[0].root_type == 'Link') {
          2
        } else {
          Infinity
        }
        Infinity
      })()}
      canDrag={canDrag}
      canDrop={canDrop}
      onChange={ treeData => { updateState(treeData, actions)}}
      generateNodeProps={({ node, path }) => {
        const flatData = getFlatDataFromTree({
          treeData: navigations, getNodeKey: ({ node }) => node.id
        })
        var nodes = flatData.map(data => data.node);
        var unpublishedNodeIds = nodes.map(
          node => node.published == false ? node.id : null
        ).filter(id => id );
        let publishStatus  = 'published'
        if(node.ancestor_ids || node.root_type == 'Page') {
          if(node.published == false ||
             node.ancestor_ids.some(r=> unpublishedNodeIds.indexOf(r) >= 0) ) {
            publishStatus = 'unpublished'
          }
        }

        return {
          className: publishStatus,
          buttons: [
            <div>
              {(() => {
                if(node.admin_edit_page_path) {
                  return (
                    <button onClick={() =>
                      FollowLink(node.admin_edit_page_path)
                    }>
                      <svg className="svg-icon" viewBox="0 0 20 20">
                        <use xlinkHref="#svg-preview"></use>
                      </svg>
                      View
                    </button>
                  )
                }
              })()}
            </div>,
            <button onClick={() =>
              FollowLink(node.admin_edit_navigation_path)
            }>
              <svg className="svg-icon" viewBox="0 0 20 20">
                <use xlinkHref="#svg-edit"></use>
              </svg>
              Edit
            </button>,
            <div>
              {(() => {
                if(
                    (node.child_type == 'Page' || node.child_type == 'Header' ||
                    node.root_type) &&
                    (navigations[0].root_type != 'Link' || node.root_type)
                  ) {
                  return (
                    <button onClick={() =>
                      FollowLink(node.add_child_path)
                    }>
                      <svg className="svg-icon" viewBox="0 0 20 20">
                        <use xlinkHref="#svg-plus"></use>
                      </svg>
                      Add Child
                    </button>
                  )
                }
              })()}
            </div>,
            <button onClick={ () => {if(confirm('Delete the navigation?')) {
              deleteNavigation(node.admin_delete_navigation_path, actions)
            };}}>
              <svg className="svg-icon" viewBox="0 0 20 20">
                <use xlinkHref="#svg-delete"></use>
              </svg>
              Remove
            </button>
          ]
        }
      }}
    />
  </div>
)

Tree.propTypes = {
  navigations: PropTypes.array.isRequired,
  actions: PropTypes.object.isRequired
}

const mapStateToProps = state => ({
  navigations: state.treeState
})

const mapDispatchToProps = dispatch => ({
  actions: bindActionCreators(TreeActions, dispatch)
})

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(Tree)

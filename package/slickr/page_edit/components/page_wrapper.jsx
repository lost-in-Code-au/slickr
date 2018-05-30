import React from 'react';
import PageForm from '../components/page_form.jsx'
import TitleBarButtons from '../components/title_bar_buttons.jsx'
import PropTypes from 'prop-types'
import ContentTab from "./content/content_tab.jsx";
import MetaTab from "./meta/meta_tab.jsx";
import SocialTab from "./social/social_tab.jsx";
import PublishingTab from "./publishing/publishing_tab.jsx";
import SchedulingModal from "./scheduling_modal.jsx";
import {editorStateFromRaw, editorStateToJSON} from "megadraft";
import { Formik } from 'formik';
import Yup from 'yup';
import cx from 'classnames';

const changeTab = function(tab, actions) {
  actions.changeTab(tab)
}

const tabClasses = (tabName, active_tab) => {
  let tab = {}
  tab[tabName] = true
  tab['active'] = active_tab == tabName
  tab['links'] = true
  return cx(tab)
}

const unpublishPage = function(actions) {
  actions.pageUnpublish()
}
const publishPage = function(actions) {
  actions.pagePublish()
}
const startScheduling = function(actions) {
  actions.startScheduling()
}
const unschedule = function(actions) {
  actions.unschedule()
}

const PageWrapper = ({schedulingActive, pageLayouts, active_tab, editorState, page, actions, values, touched, errors, dirty, isSubmitting, handleChange, setFieldValue, handleBlur, handleSubmit, handleReset, loadedImages}) => {
  return(
    <div >
      <form onSubmit={handleSubmit} id='page_edit_content_grid'>
        <div className="title_bar" id="title_bar">
          <div id="titlebar_left">
            <span className="breadcrumb">
              <a href="/admin">Admin</a>
              <span className="breadcrumb_sep"> / </span>
              <a href="/admin/slickr_pages">Pages</a>
              <span className="breadcrumb_sep"> / </span>
            </span>
            <h2 id="page_title">Edit Page</h2>
          </div>
          <div id="titlebar_right">
          <TitleBarButtons publishing_scheduled_for={page.publishing_scheduled_for} unpublishPage={unpublishPage.bind(this, actions)} publishPage={publishPage.bind(this, actions)} unschedule={unschedule.bind(this, actions)} startScheduling={startScheduling.bind(this, actions)} savePage={handleSubmit.bind(this)} page={page} editorState={editorState} actions={actions} />
          </div>
          <SchedulingModal actions={actions} modalIsOpen={schedulingActive} />
        </div>
        <PageForm actions={actions} pageLayouts={pageLayouts} setFieldValue={setFieldValue.bind(this)} handleChange={handleChange.bind(this)} active_tab={active_tab} editorState={editorState} page={page} values={values} loadedImages={loadedImages} />
      </form>
    </div>
  )
}

export default Formik({
  mapPropsToValues: (props) => ({
    title: props.page.title,
    page_header: props.page.page_header,
    slickr_image_id:  props.page.slickr_image_id,
    page_subheader: props.page.page_subheader,
    page_intro: props.page.page_intro,
    page_title: props.page.page_title,
    meta_description: props.page.meta_description,
    og_title: props.page.og_title,
    og_description: props.page.og_description,
    twitter_title: props.page.twitter_title,
    twitter_description: props.page.twitter_description,
    layout: props.page.layout,
    slug: props.page.slug
  }),
  handleSubmit: (values, { props, setErrors, setSubmitting }) => {
    // do stuff with your payload
    // e.preventDefault(), setSubmitting, setError(undefined) are
    // called before handleSubmit is. So you don't have to do repeat this.
    // handleSubmit will only be executed if form values pass validation (if you specify it).
    const content = editorStateToJSON(props.editorState)
    props.actions.updatePageContent(Object.assign({}, {content: editorStateToJSON(props.editorState)}, values))
  }
})(PageWrapper)

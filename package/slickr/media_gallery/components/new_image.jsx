import React from 'react';
import ReactDOM from 'react-dom';
import Dropzone from 'react-dropzone';

export default class NewImage extends React.Component {
  constructor() {
    super()
    this.state = { files: [] }

    this.onDrop = this.onDrop.bind(this);
  }

  onDrop(files) {
    files.forEach((file)=> {
      const formData = new FormData();
      if(file.type === 'application/pdf') {
        formData.append('slickr_media_upload[file]', file);
      } else {
        formData.append('slickr_media_upload[image]', file);
      }
      this.props.actions.createImage({
        formData: formData, file: file, upload: true
      })
    });
  }

  render() {
    return (
      <section>
        <div>
          <Dropzone
            className='dropzone'
            activeClassName='dropzone-acive'
            accept='image/jpeg, image/png, image/jpg, application/pdf'
            onDrop={this.onDrop}
          >
            <p className='main_text'>Drag and drop images here,
              <span className='alternative_text'>
                &nbsp; or select files from your computer
              </span>.
            </p>
            <p className='large-cta__hint'>
              Maximum size 10Mb | .jpeg, .jpg, .png and .pdf files only
            </p>
          </Dropzone>
        </div>
      </section>
    );
  }
}

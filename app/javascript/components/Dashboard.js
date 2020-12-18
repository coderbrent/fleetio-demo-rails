import React from "react"
import PropTypes from "prop-types"
class Dashboard extends React.Component {
  render () {
    return (
      <p>
        { this.props.welcome_msg }
      </p>
    );
  }
}

export default Dashboard

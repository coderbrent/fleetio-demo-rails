import React, { useState } from "react"

const Dashboard = props => {
  const [vendors, setVendors] = useState(props.welcome_msg);

  return (
    <div style={{ backgroundColor: 'rebeccapurple'}}>
      {vendors}
    </div>
  )
}

export default Dashboard

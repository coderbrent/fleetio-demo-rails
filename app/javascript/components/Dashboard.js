import React, { useState } from "react"

const Dashboard = props => {
  const [vendors, setVendors] = useState(JSON.parse(props.state[0]));

  return (
    <div>
      {vendors}
    </div>
  )
}

export default Dashboard

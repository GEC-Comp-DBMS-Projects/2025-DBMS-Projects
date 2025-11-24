import React from 'react'
import { View,SafeAreaView,Text } from 'react-native'

const StatusBar = ({username,userpoints}:any) => {
  return (
    <View style={{
      width:'100%',
      height:50,
      backgroundColor:'black',
      justifyContent:'center',
      alignItems:'center',
      flexDirection:'row',
      position:'absolute',
      top:0,
    }}>
      <View style={{flexDirection:'row',justifyContent:'space-between',padding:10,backgroundColor:'black'}}>
        <View>
          <Text style={{color:'white'}}>{username}</Text>
        </View>
        <View>
          <Text style={{color:'white'}}>{userpoints}</Text>
        </View>
      </View>
    </View>
  )
}

export default StatusBar
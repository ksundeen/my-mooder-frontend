import React, { useState } from 'react';
import { StyleSheet, Text, View, Alert, Button } from 'react-native';
import Geolocation from '@react-native-community/geolocation';

export function GetCurrentLocationNonExpo() {
  const getCurrentPosition = () => {
    Geolocation.getCurrentPosition(
      (pos) => {
        setPosition(JSON.stringify(pos));
      },
      (error) => Alert.alert('GetCurrentPosition Error', JSON.stringify(error)),
      { enableHighAccuracy: true }
    );
  };

  const [position, setPosition] = useState<string | null>(null);

  return (
    <View>
      <Text>
        <Text style={styles.title}>Current position: </Text>
        {position}
      </Text>
      <Button title="Get Current Position" onPress={getCurrentPosition} />
    </View>
  );
}

const styles = StyleSheet.create({
  title: {
    fontWeight: '500',
  },
});

export default GetCurrentLocationNonExpo;
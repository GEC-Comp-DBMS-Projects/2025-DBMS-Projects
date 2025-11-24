
import { SafeAreaView, useSafeAreaInsets } from 'react-native-safe-area-context';
import { PropsWithChildren } from 'react';


export default function SafeBoundingView(props:PropsWithChildren | any) {
    const insets = useSafeAreaInsets();
  return (
    <SafeAreaView className='bg-primary' style={{ paddingBottom: insets.bottom-30 }} {...props}>
     {props.children}
    </SafeAreaView>
  );
}

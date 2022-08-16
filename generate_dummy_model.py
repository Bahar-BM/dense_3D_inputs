#!/usr/bin/env python3
from tensorflow.keras.layers import Input, Dense
from tensorflow.keras.models import Model

######## TEST - Dense (3D input)  #########################
x0 = Input(shape=(23, 1024))

x1 = Dense(512)(x0)

model = Model([x0], [x1], name='test')
model.compile(optimizer='adam', loss='categorical_crossentropy', metrics=['accuracy'])
model.save('Dense_3D.h5')
model.save('Dense_3D')
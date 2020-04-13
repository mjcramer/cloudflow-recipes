/*
 * Copyright (C) 2016-2020 Lightbend Inc. <https://www.lightbend.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package sensordata

import cloudflow.akkastream._
import cloudflow.akkastream.scaladsl._
import cloudflow.streamlets.{ RoundRobinPartitioner, StreamletShape }
import cloudflow.streamlets.avro._

class SensorDataToMetrics extends AkkaStreamlet {
  val in    = AvroInlet[SensorData]("in")
  val out   = AvroOutlet[Metric]("out").withPartitioner(RoundRobinPartitioner)
  val shape = StreamletShape(in, out)
  def flow =
    FlowWithCommittableContext[SensorData]
      .filter { data =>
        data.status == "READY"
      }
      .mapConcat { data ⇒
        List(
          Metric(data.deviceId, data.timestamp, data.status, "power", data.measurements.power),
          Metric(data.deviceId, data.timestamp, data.status, "rotorSpeed", data.measurements.rotorSpeed),
          Metric(data.deviceId, data.timestamp, data.status, "windSpeed", data.measurements.windSpeed)
        )
      }
  override def createLogic = new RunnableGraphStreamletLogic() {
    def runnableGraph = sourceWithOffsetContext(in).via(flow).to(committableSink(out))
  }
}

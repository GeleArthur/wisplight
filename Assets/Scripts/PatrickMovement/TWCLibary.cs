using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TWCLibary
{
    public static class TransformExtender
    {
        public static Vector3 RotateAround(Vector3 origin, Vector3 point, Vector3 axis, float angle)
        {
            Quaternion rot = Quaternion.AngleAxis(angle, axis); //get the quaternion from the axis and angle
            Matrix4x4 test = Matrix4x4.TRS(origin, rot, Vector3.one); //create a matrix to do the heavy calculating
            return test.MultiplyPoint(point) - origin; //and calculate

            //thanks:
            //https://www.youtube.com/watch?v=FqiGuTtjmMg
            //https://www.youtube.com/watch?v=HV2kFn2hjkk
            //okey they werent that helpfull but it was a good start
        }

        [System.Obsolete("Unity has a built in function called Quaternion.AngleAxis, its faster")] //well alteast i learned something
        public static Quaternion AxisAngleToQuaternion(Vector3 axis, float angle)
        {
            if (axis.sqrMagnitude == 0f)
            {
                Debug.Log("Axis is zero");
                return Quaternion.identity;
            }

            float s = Mathf.Sin((angle / 2f) * Mathf.Deg2Rad);
            float x = axis.x * s;
            float y = axis.y * s;
            float z = axis.z * s;
            float w = Mathf.Cos((angle / 2f) * Mathf.Deg2Rad);
            return new Quaternion(x, y, z, w);

            //thanks:
            //http://euclideanspace.com/maths/geometry/rotations/conversions/angleToQuaternion/index.htm
        }

        public static Quaternion QuaternionSmoothDamp(Quaternion current, Quaternion target, ref float currentVelocity, float smoothTime, float maxSpeed = float.PositiveInfinity, float deltaTime = float.NaN)
        {
            if (float.IsNaN(deltaTime))
                deltaTime = Time.deltaTime;

            float delta = Quaternion.Angle(current, target);
            if (delta > 0f)
            {
                float t = Mathf.SmoothDampAngle(delta, 0.0f, ref currentVelocity, smoothTime, maxSpeed, deltaTime);
                t = 1.0f - (t / delta);
                return Quaternion.Slerp(current, target, t);
            }

            return current;

            //https://answers.unity.com/questions/390291/is-there-a-way-to-smoothdamp-a-lookat.html?childToView=1486611#answer-1486611
            //thanks idbrii
        }
    }
}